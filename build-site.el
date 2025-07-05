(setq inhibit-startup-screen t)
(setq inhibit-splash-screen t)
(setq inhibit-x-resources t)
(setq image-use-imagemagick nil)
;; Set the package installation directory so that packages aren't stored in the
;; ~/.emacs.d/elpa path.
(require 'package)
(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

;; Initialize the package system
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Install dependencies
(package-install 'htmlize)

;; Load the publishing system
(require 'ox-publish)

;; Customize the HTML output
(setq org-html-validation-link nil            ;; Don't show validation link
      org-html-head-include-scripts nil       ;; Use our own scripts
      org-html-head-include-default-style nil ;; Use our own styles
      org-html-head "<link rel=\"stylesheet\" href=\"style.css\" />")

;; Define the publishing project
(setq org-publish-project-alist
      (list
       (list "org-site:main"
             :recursive t
             :base-directory "./content"
             :publishing-function 'org-html-publish-to-html
             :publishing-directory "./public"
             :with-author nil           ;; Don't include author name
             :with-creator t            ;; Include Emacs and Org versions in footer
             :with-toc t                ;; Include a table of contents
             :section-numbers nil       ;; Don't include section numbers
             :time-stamp-file nil
	     :html-head "<link rel=\"stylesheet\" href=\"style.css\" />"
             :html-head-extra (when (file-exists-p "header.html")
                                (with-temp-buffer
                                  (insert-file-contents "header.html")
                                  (buffer-string)))
             :html-postamble "<script>
(function() {
  const toggle = document.getElementById('dark-toggle');
  if (!toggle) return;

  // Check stored preference or system preference
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  const isDark = localStorage.getItem('darkMode') === 'true' || (localStorage.getItem('darkMode') === null && prefersDark);

  if (isDark) {
    document.body.classList.add('dark');
    toggle.textContent = '☀️';
  }

  toggle.addEventListener('click', () => {
    document.body.classList.toggle('dark');
    const currentlyDark = document.body.classList.contains('dark');
    toggle.textContent = currentlyDark ? '☀️' : '🌙';
    localStorage.setItem('darkMode', currentlyDark);
  });
})();
</script>")))    ;; Don't include time stamp in file

;; Add static files (like CSS) to be copied over
(setq org-publish-project-alist
      (append
       org-publish-project-alist
       (list
        (list "org-site:assets"
              :base-directory "."     ;; Current dir
              :base-extension "css"   ;; Only CSS files
              :publishing-directory "./public"
              :recursive nil
              :publishing-function 'org-publish-attachment))))

;; Generate the site output
(org-publish-all t)

(message "Build complete!")

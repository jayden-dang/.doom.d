;; global mode
(global-subword-mode 1)
(add-to-list 'load-path "~/.doom.d/lisp")

(setq user-full-name "Jayden Dang"
      user-mail-address "jayden.dangvu@gmail.com"

      ;; Split horizontally to right, vertically below the current window.
      evil-vsplit-window-right t
      evil-split-window-below t

      ;; Enable relative line number
      display-line-numbers-type 'relative

      source-directory (expand-file-name "~/.emacs.d/")
      )

;; Enable line numbers for some modes
(column-number-mode)
(dolist (mode '(text-mode-hook
                prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))

;; Override some modes which derive from the above
(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq-default delete-by-moving-to-trash t ;; Delete files by moving them to trash.
              trash-directory nil

              ;; Take new window space from all other windows
              window-combination-resize t
              ;; stretch cursor to the glyph width
              x-stretch-cursor t
              )

(defvar +my/lang-main          "en")
(defvar +my/lang-secondary     "cn")
(defvar +my/lang-mother-tongue "vn")

;; Set it early, to avoid creating "~/org" at startup
(setq org-directory "~/Areas/JSystem/Org")
(setq org-agenda-files (directory-files-recursively org-directory "\\.org$"))

(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (consult-buffer))

;;;###autoload
(defun jayden/edit-zsh-configuration ()
  (interactive)
  (find-file "~/.zshrc"))

;;;###autoload
(defun jayden/use-eslint-from-node-modules ()
    "Set local eslint if available."
    (let* ((root (locate-dominating-file
                  (or (buffer-file-name) default-directory)
                  "node_modules"))
           (eslint (and root
                        (expand-file-name "node_modules/eslint/bin/eslint.js"
                                          root))))
      (when (and eslint (file-executable-p eslint))
        (setq-local flycheck-javascript-eslint-executable eslint))))

;;;###autoload
(defun jayden/goto-match-paren (arg)
  "Go to the matching if on (){}[], similar to vi style of % ."
  (interactive "p")
  (cond ((looking-at "[\[\(\{]") (evil-jump-item))
        ((looking-back "[\]\)\}]" 1) (evil-jump-item))
        ((looking-at "[\]\)\}]") (forward-char) (evil-jump-item))
        ((looking-back "[\[\(\{]" 1) (backward-char) (evil-jump-item))
        (t nil)))

;;;###autoload
(defun jayden/string-inflection-cycle-auto ()
  "switching by major-mode"
  (interactive)
  (cond
   ;; for emacs-lisp-mode
   ((eq major-mode 'emacs-lisp-mode)
    (string-inflection-all-cycle))
   ;; for python
   ((eq major-mode 'python-mode)
    (string-inflection-python-style-cycle))
   ;; for java
   ((eq major-mode 'java-mode)
    (string-inflection-java-style-cycle))
   (t
    ;; default
    (string-inflection-all-cycle))))

;; Current time and date
(defvar current-date-time-format "%Y-%m-%d %H:%M:%S"
  "Format of date to insert with `insert-current-date-time' func
See help of `format-time-string' for possible replacements")

(defvar current-time-format "%H:%M:%S"
  "Format of date to insert with `insert-current-time' func.
Note the weekly scope of the command's precision.")

;;;###autoload
(defun insert-current-date-time ()
  "insert the current date and time into current buffer.
Uses `current-date-time-format' for the formatting the date/time."
  (interactive)
  (insert (format-time-string current-date-time-format (current-time)))
  )

;;;###autoload
(defun insert-current-time ()
  "insert the current time (1-week scope) into the current buffer."
  (interactive)
  (insert (format-time-string current-time-format (current-time)))
  )

;;;###autoload
(defun my/capitalize-first-char (&optional string)
  "Capitalize only the first character of the input STRING."
  (when (and string (> (length string) 0))
    (let ((first-char (substring string nil 1))
          (rest-str   (substring string 1)))
      (concat (capitalize first-char) rest-str))))

;;;###autoload
(defun my/lowcase-first-char (&optional string)
  "Capitalize only the first character of the input STRING."
  (when (and string (> (length string) 0))
    (let ((first-char (substring string nil 1))
          (rest-str   (substring string 1)))
      (concat first-char rest-str))))

;;;###autoload
(defun jayden/async-shell-command-silently (command)
  "async shell command silently."
  (interactive)
  (let
      ((display-buffer-alist
        (list
         (cons
          "\\*Async Shell Command\\*.*"
          (cons #'display-buffer-no-window nil)))))
    (async-shell-command
     command)))

(defun scroll-half-page-down ()
  "scroll down half the page"
  (interactive)
  (scroll-down (/ (window-body-height) 2)))

(defun scroll-half-page-up ()
  "scroll up half the page"
  (interactive)
  (scroll-up (/ (window-body-height) 2)))

(defun +pkm/org-files (&rest segments)
  "Return a flat list of Org files inside SEGMENTS relative to `org-directory`."
  (apply #'append
         (mapcar (lambda (segment)
                   (let ((path (expand-file-name segment org-directory)))
                     (cond
                      ((file-directory-p path)
                       (directory-files-recursively path "\\.org$"))
                      ((file-readable-p path) (list path))
                      (t nil))))
                 segments)))

(defun +pkm/org-all-files ()
  "Return unique Org files participating in the PKM system."
  (seq-uniq
   (append
    (mapcar (lambda (file)
              (expand-file-name file org-directory))
            '("todo.org" "notes.org" "projects.org" "journal.org" "workflow-example.org" "system-charter.org"))
    (+pkm/org-files "Roam/Areas" "Roam/Projects" "Roam/Capture" "Roam/Creation" "Roam/Resources"))))

(defun +pkm/agenda-skip-recent-review (days)
  "Skip subtree if its LAST_REVIEW property is within DAYS days."
  (let ((last-review (org-entry-get (point) "LAST_REVIEW")))
    (when last-review
      (let* ((ts (org-time-string-to-time last-review))
             (threshold (time-subtract (current-time) (days-to-time days))))
        (when (and ts (not (time-less-p ts threshold)))
          (org-with-wide-buffer
            (org-end-of-subtree t))
          (point))))))

(defun +pkm/org-recent-notes ()
  "Show headings with timestamps in the last 14 days across the PKM system."
  (interactive)
  (org-ql-search (+pkm/org-all-files)
                 '(ts :from -14 :to today)
                 :title "Recent (last 14 days)"
                 :sort '(date descending)))

(defun +pkm/org-keyword-search (keywords)
  "Search PKM notes for KEYWORDS using `org-ql'."
  (interactive "sKeyword(s): ")
  (unless (string-blank-p keywords)
    (org-ql-search (+pkm/org-all-files)
                   `(regexp ,keywords)
                   :title (format "Keyword search: %s" keywords)
                   :sort '(date descending))))

(defun +pkm/org-materials-needed ()
  "Open an agenda view for entries tagged NEEDS."
  (interactive)
  (org-tags-view nil "+NEEDS"))

(defun +pkm/org-publishing-candidates ()
  "Open an agenda view for entries tagged SHARE."
  (interactive)
  (org-tags-view nil "+SHARE"))

(after! org
  (require 'seq)
  (require 'subr-x)
  (require 'org-id)
  (require 'org-protocol)
  (require 'org-ql)
  (require 'org-ql-view)
  (require 'server)
  (unless (server-running-p)
    (server-start))

  (setq org-id-link-to-org-use-id 'create-if-interactive
        org-log-into-drawer t
        org-log-reschedule 'time
        org-log-redeadline 'time
        org-log-done 'time)

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n!)" "ACTIVE(a!)" "WAITING(w@/!)" "SOMEDAY(s)" "|"
                    "DONE(d!)" "CANCELLED(c@)")
          (sequence "IDEA(i)" "DRAFT(d)" "EDIT(e)" "READY(r)" "PUBLISHED(p)" "|"
                    "ARCHIVED(x)")))
  (setq org-todo-keyword-faces
        '(("NEXT" . +org-todo-active)
          ("ACTIVE" . +org-todo-project)
          ("WAITING" . +org-todo-onhold)
          ("SOMEDAY" . +org-todo-onhold)
          ("IDEA" . +org-todo-onhold)
          ("DRAFT" . +org-todo-active)
          ("EDIT" . +org-todo-active)
          ("READY" . +org-todo-active)
          ("PUBLISHED" . +org-todo-done)
          ("ARCHIVED" . +org-todo-cancel)))

  (setq org-tag-alist
        '(("@area/personal" . ?p)
          ("@area/work" . ?w)
          ("@area/learning" . ?l)
          ("@project" . ?P)
          ("NEEDS" . ?m)
          ("SHARE" . ?s)
          ("L-CRITICAL" . ?c)))
  (setq org-tag-persistent-alist org-tag-alist)

  (let ((todo-file (expand-file-name "todo.org" org-directory))
        (notes-file (expand-file-name "notes.org" org-directory))
        (journal-file (expand-file-name "journal.org" org-directory)))
    (setq org-default-notes-file notes-file)
    (setq org-capture-templates
          `(("t" "Task" entry (file+headline ,todo-file "Inbox")
             "* TODO %^{Task}\n:PROPERTIES:\n:ID: %(org-id-uuid)\n:CREATED: %U\n:AREA: %^{Area|}\n:PROJECT: %^{Project|}\n:SOURCE: %^{Source|}\n:KEYWORDS: %^{Keywords|}\n:END:\n%?"
             :prepend t :empty-lines 1 :kill-buffer t)
            ("n" "Note (triage)" entry (file+headline ,notes-file "Inbox")
             "* %^{Title}\n:PROPERTIES:\n:ID: %(org-id-uuid)\n:CREATED: %U\n:AREA: %^{Area|}\n:PROJECT: %^{Project|}\n:KEYWORDS: %^{Keywords|}\n:SOURCE: %^{Source|}\n:END:\n%?"
             :prepend t :empty-lines 1 :kill-buffer t)
            ("j" "Journal" entry (file+datetree ,journal-file)
             "* %^{Focus}\n:PROPERTIES:\n:CREATED: %U\n:MOOD: %^{Mood|}\n:ENERGY: %^{Energy|}\n:END:\n%?"
             :empty-lines 1)
            ("w" "Web capture (org-protocol)" entry (file+headline ,notes-file "Inbox")
             "* %:description\n:PROPERTIES:\n:ID: %(org-id-uuid)\n:CREATED: %U\n:SOURCE: %:link\n:CONTEXT: %^{Context|}\n:KEYWORDS: %^{Keywords|}\n:END:\n\n%?"
             :prepend t :empty-lines 1 :immediate-finish nil :kill-buffer t))))

  (let* ((todo-file (expand-file-name "todo.org" org-directory))
         (projects-file (expand-file-name "projects.org" org-directory))
         (notes-file (expand-file-name "notes.org" org-directory))
         (journal-file (expand-file-name "journal.org" org-directory))
         (creation-files (+pkm/org-files "Roam/Creation"))
         (stale-files (append (+pkm/org-files "Roam/Areas")
                              (+pkm/org-files "Roam/Projects")))
         (resource-files (+pkm/org-files "Roam/Resources"))
         (all-files (seq-uniq (append (list todo-file projects-file notes-file journal-file)
                                      creation-files stale-files resource-files))))
    (setq org-agenda-start-with-log-mode t
          org-agenda-log-mode-items '(closed clock))
    (setq org-agenda-custom-commands
          `(("d" "Daily Dashboard"
             ((agenda "" ((org-agenda-span 1)
                          (org-agenda-start-day "+0d")
                          (org-agenda-overriding-header "Today")
                          (org-agenda-skip-deadline-if-done t)
                          (org-agenda-skip-scheduled-if-done t)))
              (todo "NEXT"
                    ((org-agenda-overriding-header "Next Actions")
                     (org-agenda-files (list ,todo-file))))
              (todo "WAITING"
                    ((org-agenda-overriding-header "Waiting On")
                     (org-agenda-files (list ,todo-file))))))
            ("w" "Weekly Review"
             ((agenda "" ((org-agenda-span 7)
                          (org-agenda-start-on-weekday 1)
                          (org-agenda-overriding-header "Week Overview")))
              (todo "ACTIVE"
                    ((org-agenda-overriding-header "Active Projects")
                     (org-agenda-files (list ,projects-file))))
              (todo "SOMEDAY"
                    ((org-agenda-overriding-header "Someday / Maybe")
                     (org-agenda-files (list ,todo-file))))
              (tags "REV_STAGE={DRAFT\\|EDIT}"
                    ((org-agenda-overriding-header "Creation Pipeline")
                     (org-agenda-files ,(or creation-files
                                             (list (expand-file-name "Roam/Creation" org-directory))))))))
            ("s" "Stale Notes (>90d)"
             ((tags "+LEVEL<=2"
                    ((org-agenda-overriding-header "Stale Notes (>90 days since last review)")
                     (org-tags-match-list-sublevels 'indented)
                     (org-agenda-files ,(or stale-files
                                             (list projects-file)))
                     (org-agenda-skip-function (lambda () (+pkm/agenda-skip-recent-review 90))))))
            ("R" "Recent (14d timestamps)" org-ql-block
             ((org-ql-block-header "Recent entries (last 14 days)")
              (org-ql ,all-files
                '(ts :from -14 :to today)
                ((org-ql-block-item :todo-and-heading)))))
            ("K" "Keyword search" search ""
             ((org-agenda-files ,all-files)
              (org-agenda-overriding-header "Keyword search (prompt)")))
            ("M" "Materials Needed" tags "+NEEDS"
             ((org-agenda-overriding-header "Materials / resources required")
              (org-tags-match-list-sublevels 'indented)))
            ("P" "Publishing candidates" tags "+SHARE"
             ((org-agenda-overriding-header "Publishing candidates (:SHARE:)")))
            )))))

;; Increase undo history limits even more
(after! undo-fu
  (setq undo-limit        10000000     ;; 1MB   (default is 160kB, Doom's default is 400kB)
        undo-strong-limit 100000000    ;; 100MB (default is 240kB, Doom's default is 3MB)
        undo-outer-limit  1000000000)) ;; 1GB   (default is 24MB,  Doom's default is 48MB)

(after! evil
  (setq evil-want-fine-undo t)) ;; By default while in insert all changes are one big blob

(use-package! vundo
  :defer t
  :init
  (defconst +vundo-unicode-symbols
   '((selected-node   . ?●)
     (node            . ?○)
     (vertical-stem   . ?│)
     (branch          . ?├)
     (last-branch     . ?╰)
     (horizontal-stem . ?─)))

  (map! :leader
        (:prefix ("o")
         :desc "vundo" "v" #'vundo))

  :config
  (setq vundo-glyph-alist +vundo-unicode-symbols
        vundo-compact-display t
        vundo-window-max-height 6))

(setq browse-url-browser-function 'browse-url-default-macosx-browser)

(defvar +messages--auto-tail-enabled nil)

(defun +messages--auto-tail-a (&rest arg)
  "Make *Messages* buffer auto-scroll to the end after each message."
  (let* ((buf-name (buffer-name (messages-buffer)))
         ;; Create *Messages* buffer if it does not exist
         (buf (get-buffer-create buf-name)))
    ;; Activate this advice only if the point is _not_ in the *Messages* buffer
    ;; to begin with. This condition is required; otherwise you will not be
    ;; able to use `isearch' and other stuff within the *Messages* buffer as
    ;; the point will keep moving to the end of buffer :P
    (when (not (string= buf-name (buffer-name)))
      ;; Go to the end of buffer in all *Messages* buffer windows that are
      ;; *live* (`get-buffer-window-list' returns a list of only live windows).
      (dolist (win (get-buffer-window-list buf-name nil :all-frames))
        (with-selected-window win
          (goto-char (point-max))))
      ;; Go to the end of the *Messages* buffer even if it is not in one of
      ;; the live windows.
      (with-current-buffer buf
        (goto-char (point-max))))))

(defun +messages-auto-tail-toggle ()
  "Auto tail the '*Messages*' buffer."
  (interactive)
  (if +messages--auto-tail-enabled
      (progn
        (advice-remove 'message '+messages--auto-tail-a)
        (setq +messages--auto-tail-enabled nil)
        (message "+messages-auto-tail: Disabled."))
    (advice-add 'message :after '+messages--auto-tail-a)
    (setq +messages--auto-tail-enabled t)
    (message "+messages-auto-tail: Enabled.")))

(setq doom-font (font-spec :family "Iosevka Fixed Curly Slab" :size 15)
      doom-big-font (font-spec :family "Iosevka Fixed Curly Slab" :size 20 :weight 'light)
      doom-variable-pitch-font (font-spec :family "Iosevka Fixed Curly Slab")
      doom-unicode-font (font-spec :family "JuliaMono")
      doom-serif-font (font-spec :family "Iosevka Fixed Curly Slab" :weight 'light))

(setq doom-theme 'modus-vivendi)
;; (remove-hook 'window-setup-hook #'doom-init-theme-h)
;; (add-hook 'after-init-hook #'doom-init-theme-h 'append)

(after! doom-modeline
  (setq display-time-string-forms
        '((propertize (concat " 🕘 " 24-hours ":" minutes))))
  (display-time-mode 1) ; Enable time in the mode-line

  ;; Add padding to the right
  (doom-modeline-def-modeline 'main
   '(bar workspace-name window-number modals matches buffer-info remote-host buffer-position word-count parrot selection-info)
   ;; '(objed-state misc-info persp-name battery grip github debug repl lsp minor-modes input-method indent-info buffer-encoding process vcs checker "   ")
   ))

(after! doom-modeline
  (let ((battery-str (battery)))
    (unless (or (equal "Battery status not available" battery-str)
                (string-match-p (regexp-quote "unknown") battery-str)
                (string-match-p (regexp-quote "N/A") battery-str))
      (display-battery-mode 1))))

(after! doom-modeline
  (setq doom-modeline-bar-width 4
        doom-modeline-mu4e t
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode-color-icon t
        doom-modeline-buffer-file-name-style 'truncate-upto-project))

;; set transparent
(set-frame-parameter (selected-frame) 'alpha '(100 100))
(add-to-list 'default-frame-alist '(alpha 100 100))

;; full screen
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-hook 'org-mode-hook 'turn-on-auto-fill)

(setq fancy-splash-image (expand-file-name "assets/doom-emacs-gray.svg" doom-user-dir))

(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-footer)
(add-hook! '+doom-dashboard-mode-hook (hl-line-mode -1))
(setq-hook! '+doom-dashboard-mode-hook evil-normal-state-cursor (list nil))

(use-package! svg-tag-mode
  :commands svg-tag-mode
  :config
  (setq svg-tag-tags
        '(("^\\*.* .* \\(:[A-Za-z0-9]+\\)" .
           ((lambda (tag)
              (svg-tag-make
               tag
               :beg 1
               :font-family "Roboto Mono"
               :font-size 10
               :height 0.8
               :padding 0
               :margin 0))))
          ("\\(:[A-Za-z0-9]+:\\)$" .
           ((lambda (tag)
              (svg-tag-make
               tag
               :beg 1
               :end -1
               :font-family "Roboto Mono"
               :font-size 10
               :height 0.8
               :padding 0
               :margin 0)))))))

(after! svg-lib
  ;; Set `svg-lib' cache directory
  (setq svg-lib-icons-dir (expand-file-name "svg-lib" doom-data-dir)))

(use-package! focus
  :commands focus-mode)

;; (after! all-the-icons
;;   (setcdr (assoc "m" all-the-icons-extension-icon-alist)
;;           (cdr (assoc "matlab" all-the-icons-extension-icon-alist))))

(after! writeroom-mode
  ;; Show mode line
  (setq writeroom-mode-line t)

  ;; Disable line numbers
  (add-hook! 'writeroom-mode-enable-hook
    (when (bound-and-true-p display-line-numbers-mode)
      (setq-local +line-num--was-activate-p display-line-numbers-type)
      (display-line-numbers-mode -1)))

  (add-hook! 'writeroom-mode-disable-hook
    (when (bound-and-true-p +line-num--was-activate-p)
      (display-line-numbers-mode +line-num--was-activate-p)))

  (after! org
    ;; Increase latex previews scale in Zen mode
    (add-hook! 'writeroom-mode-enable-hook (+org-format-latex-set-scale 2.0))
    (add-hook! 'writeroom-mode-disable-hook (+org-format-latex-set-scale 1.4)))

  (after! blamer
    ;; Disable blamer in zen (writeroom) mode
    (add-hook! 'writeroom-mode-enable-hook
      (when (bound-and-true-p blamer-mode)
        (setq +blamer-mode--was-active-p t)
        (blamer-mode -1)))
    (add-hook! 'writeroom-mode-disable-hook
      (when (bound-and-true-p +blamer-mode--was-active-p)
        (blamer-mode 1)))))

(after! highlight-indent-guides
  (setq highlight-indent-guides-character ?│
        highlight-indent-guides-responsive 'top))

(global-set-key (kbd "<f1>") nil)        ; ns-print-buffer
(global-set-key (kbd "<f2>") nil)        ; ns-print-buffer
(define-key evil-normal-state-map (kbd ",") nil)
(define-key evil-visual-state-map (kbd ",") nil)
(define-key evil-normal-state-map (kbd "K") 'eldoc)

;; (global-set-key (kbd "<f2>") 'rgrep)
;; (global-set-key (kbd "K") 'eldoc)
;; (global-set-key (kbd "<f5>") 'deadgrep)
;; (global-set-key (kbd "<M-f5>") 'deadgrep-kill-all-buffers)
;; (global-set-key (kbd "<f8>") 'quickrun)
;; (global-set-key (kbd "<f12>") 'smerge-vc-next-conflict)
(global-set-key (kbd "M-z") 'jayden-launcher/body)
;; (global-set-key (kbd "C-t") '+vterm/toggle)
;; (global-set-key (kbd "C-S-t") '+vterm/here)
;; (global-set-key (kbd "C-d") 'kill-current-buffer)
;; (global-set-key (kbd "C-c C-j") 'avy-resume)

(setq doom-localleader-key ",")
(map!
 ;; avy
 :nv    "f"     #'avy-goto-char-2
 :nv    "F"     #'avy-goto-char
 :nv    "w"     #'avy-goto-word-1
 :nv    "W"     #'avy-goto-char-timer

;; view scroll mode
:nv    "C-n"   #'scroll-half-page-up
:nv    "C-p"   #'scroll-half-page-down

:nv    "@@"   #'hs-toggle-hiding

:nv    "-"     #'evil-window-decrease-width
:nv    "+"     #'evil-window-increase-width
:nv    "C--"   #'evil-window-decrease-height
:nv    "C-+"   #'evil-window-increase-height

:nv    ")"     #'sp-forward-sexp
:nv    "("     #'sp-backward-up-sexp
:nv    "s-)"   #'sp-down-sexp
:nv    "s-("   #'sp-backward-sexp
:nv    "gd"    #'xref-find-definitions
:nv    "gr"    #'xref-find-references
:nv    "gb"    #'xref-pop-marker-stack

:niv   "C-e"   #'evil-end-of-line
:niv   "C-="   #'er/expand-region

"C-;"          #'tiny-expand
"C-a"          #'crux-move-beginning-of-line
"C-s"          #'+default/search-buffer

"C-c C-j"      #'avy-resume
"C-c c x"      #'org-capture
;; "C-c c j"      #'avy-resume

"C-c f r"      #'jayden/indent-org-block-automatically

"C-c h h"      #'jayden/org-html-export-to-html

"C-c i d"      #'insert-current-date-time
"C-c i t"      #'insert-current-time
;; "C-c i d"      #'crux-insert-date
"C-c i e"      #'emojify-inert-emoji
"C-c i f"      #'js-doc-insert-function-doc
"C-c i F"      #'js-doc-insert-file-doc

"C-c o o"      #'crux-open-with
"C-c o u"      #'crux-view-url
"C-c o t"      #'crux-visit-term-buffer

"C-c r r"      #'vr/replace
"C-c r q"      #'vr/query-replace

;; Command/Window
"s-k"          #'move-text-up
"s-j"          #'move-text-down
"s-i"          #'jayden/string-inflection-cycle-auto
;; "s--"          #'sp-splice-sexp
;; "s-_"          #'sp-rewrap-sexp

"M-i"          #'parrot-rotate-next-word-at-point
"s-;"          #'jayden/goto-match-paren
)

(map! :leader
      :n "SPC"  #'execute-extended-command
      :n "."  #'dired-jump
      :n ","  #'magit-status
      :n "-"  #'goto-line

      ;; lsp

      (:prefix ("l" . "Exercise Coding Challenger")
       :n    "l"     #'leetcode
       :n    "d"     #'leetcode-daily
       :n    "o"     #'leetcode-show-problem-in-browser
       :n    "s"     #'leetcode-show-problem
       )

      ;; (:prefix ("d" . "Debugger")
      ;;  :n    "r"   #'dap-debug
      ;;  :n    "l"   #'dap-debug-last
      ;;  :n    "R"   #'dap-debug-recent
      ;;  :n    "x"   #'dap-disconnect
      ;;  :n    "a"   #'dap-breakpoint-add
      ;;  :n    "t"   #'dap-breakpoint-toggle
      ;;  :n    "d"   #'dap-delete-session
      ;;  :n    "D"   #'dap-delete-all-sessions

      ;;  )

      (:prefix ("e" . "Exercise Coding Challenger")
       :n    "l"     #'leetcode
       :n    "d"     #'leetcode-daily
       :n    "o"     #'leetcode-show-problem-in-browser
       :n    "s"     #'leetcode-show-problem
       )


      (:prefix ("m" . "Treemacs")
       :n     "t"           #'treemacs
       :n     "df"           #'treemacs-delete-file
       :n     "dp"           #'treemacs-remove-project-from-workspace
       :n     "cd"           #'treemacs-create-dir
       :n     "cf"           #'treemacs-create-file
       :n     "a"           #'treemacs-add-project-to-workspace
       :n     "wc"           #'treemacs-create-workspace
       :n     "ws"           #'treemacs-switch-workspace
       :n     "wd"           #'treemacs-remove-workspace
       :n     "wf"           #'treemacs-rename-workspace
       )

      (:prefix ("oA" . "Agenda+")
       :desc "Recent notes (14d)" "r" #'+pkm/org-recent-notes
       :desc "Keyword search (org-ql)" "k" #'+pkm/org-keyword-search
       :desc "Materials needed" "m" #'+pkm/org-materials-needed
       :desc "Publishing candidates" "p" #'+pkm/org-publishing-candidates)

      :nv "w -" #'evil-window-split
      :nv "j" #'switch-to-buffer
      :nv "wo" #'delete-other-windows
      :nv "fd" #'doom/delete-this-file
      :nv "ls" #'+lsp/switch-client
      :nv "bR" #'rename-buffer
      :nv "bx" #'doom/switch-to-scratch-buffer
      )

;; (map! :map dap-mode-map
;;       :leader
;;       :prefix ("d" . "dap")
;;       ;; basics
;;       :desc "dap next"          "n" #'dap-next
;;       :desc "dap step in"       "i" #'dap-step-in
;;       :desc "dap step out"      "o" #'dap-step-out
;;       :desc "dap continue"      "c" #'dap-continue
;;       :desc "dap hydra"         "h" #'dap-hydra
;;       :desc "dap debug restart" "r" #'dap-debug-restart
;;       :desc "dap debug"         "s" #'dap-debug

;;       ;; debug
;;       :prefix ("dd" . "Debug")
;;       :desc "dap debug recent"  "r" #'dap-debug-recent
;;       :desc "dap debug last"    "l" #'dap-debug-last

;;       ;; eval
;;       :prefix ("de" . "Eval")
;;       :desc "eval"                "e" #'dap-eval
;;       :desc "eval region"         "r" #'dap-eval-region
;;       :desc "eval thing at point" "s" #'dap-eval-thing-at-point
;;       :desc "add expression"      "a" #'dap-ui-expressions-add
;;       :desc "remove expression"   "d" #'dap-ui-expressions-remove

;;       :prefix ("db" . "Breakpoint")
;;       :desc "dap breakpoint toggle"      "b" #'dap-breakpoint-toggle
;;       :desc "dap breakpoint condition"   "c" #'dap-breakpoint-condition
;;       :desc "dap breakpoint hit count"   "h" #'dap-breakpoint-hit-condition
;;       :desc "dap breakpoint log message" "l" #'dap-breakpoint-log-message)

(map! :map org-mode-map
      ;; t
      :nv "tt"          #'org-todo
      :nv "tT"          #'counsel-org-tag

      :nv "tcc"         #'org-toggle-checkbox
      :nv "tcu"         #'org-update-checkbox-count

      :nv "tpp"         #'org-priority
      :nv "tpu"         #'org-priority-up
      :nv "tpd"         #'org-priority-down


      ;; C-c
      "C-c a t" #'org-transclusion-add
      ;; #'org-transclusion-mode
      "C-c c i" #'org-clock-in
      "C-c c o" #'org-clock-out
      "C-c c h" #'counsel-org-clock-history
      "C-c c g" #'counsel-org-clock-goto
      "C-c c c" #'counsel-org-clock-context
      "C-c c r" #'counsel-org-clock-rebuild-history
      "C-c c p" #'org-preview-html-mode

      "C-c f r" #'jayden/indent-org-block-automatically

      "C-c e e" #'all-the-icons-insert
      "C-c e a" #'all-the-icons-insert-faicon
      "C-c e f" #'all-the-icons-insert-fileicon
      "C-c e w" #'all-the-icons-insert-wicon
      "C-c e o" #'all-the-icons-insert-octicon
      "C-c e m" #'all-the-icons-insert-material
      "C-c e i" #'all-the-icons-insert-alltheicon

      "C-c g l" #'org-mac-grab-link

      "C-c i u" #'org-mac-chrome-insert-frontmost-url
      "C-c i c" #'copyright
      "C-c i D" #'o-docs-insert

      )

(map! :map deadgrep-mode-map
      :nv "TAB" #'deadgrep-toggle-file-results
      :nv "D"   #'deadgrep-directory
      :nv "S"   #'deadgrep-search-term
      :nv "N"   #'deadgrep--move-match
      :nv "n"   #'deadgrep--move
      :nv "o"   #'deadgrep-visit-result-other-window
      :nv "r"   #'deadgrep-restart)

(set-file-template! "\\.tex$" :trigger "__" :mode 'latex-mode)
(set-file-template! "\\.org$" :trigger "__" :mode 'org-mode)
(set-file-template! "/LICEN[CS]E$" :trigger '+file-templates/insert-license)

(setq doom-scratch-initial-major-mode 'emacs-lisp-mode)

(use-package! vlf-setup
  :defer-incrementally vlf-tune vlf-base vlf-write vlf-search vlf-occur vlf-follow vlf-ediff vlf)

(after! evil
  ;; This fixes https://github.com/doomemacs/doomemacs/issues/6478
  ;; Ref: https://github.com/emacs-evil/evil/issues/1630
  (evil-select-search-module 'evil-search-module 'isearch)

  (setq evil-kill-on-visual-paste nil)) ; Don't put overwritten text in the kill ring

(use-package! aggressive-indent
  :commands (aggressive-indent-mode))

(setq yas-triggers-in-field t)

(setq emojify-emoji-set "twemoji-v2")

(defvar emojify-disabled-emojis
  '(;; Org
    "◼" "☑" "☸" "⚙" "⏩" "⏪" "⬆" "⬇" "❓" "⏱" "®" "™" "🅱" "❌" "✳"
    ;; Terminal powerline
    "✔"
    ;; Box drawing
    "▶" "◀")
  "Characters that should never be affected by `emojify-mode'.")

(defadvice! emojify-delete-from-data ()
  "Ensure `emojify-disabled-emojis' don't appear in `emojify-emojis'."
  :after #'emojify-set-emoji-data
  (dolist (emoji emojify-disabled-emojis)
    (remhash emoji emojify-emojis)))

(defun emojify--replace-text-with-emoji (orig-fn emoji text buffer start end &optional target)
  "Modify `emojify--propertize-text-for-emoji' to replace ascii/github emoticons with unicode emojis, on the fly."
  (if (or (not emoticon-to-emoji) (= 1 (length text)))
      (funcall orig-fn emoji text buffer start end target)
    (delete-region start end)
    (insert (ht-get emoji "unicode"))))

(define-minor-mode emoticon-to-emoji
  "Write ascii/gh emojis, and have them converted to unicode live."
  :global nil
  :init-value nil
  (if emoticon-to-emoji
      (progn
        (setq-local emojify-emoji-styles '(ascii github unicode))
        (advice-add 'emojify--propertize-text-for-emoji :around #'emojify--replace-text-with-emoji)
        (unless emojify-mode
          (emojify-turn-on-emojify-mode)))
    (setq-local emojify-emoji-styles (default-value 'emojify-emoji-styles))
    (advice-remove 'emojify--propertize-text-for-emoji #'emojify--replace-text-with-emoji)))

(add-hook! '(mu4e-compose-mode org-msg-edit-mode circe-channel-mode) (emoticon-to-emoji 1))

(defun +appened-to-negation-list (head tail)
  (if (sequencep head)
      (delete-dups
       (if (eq (car tail) 'not)
           (append head tail)
         (append tail head)))
    tail))

(when (modulep! :ui ligatures)
  (setq +ligatures-extras-in-modes
        (+appened-to-negation-list
         +ligatures-extras-in-modes
         '(not c-mode c++-mode emacs-lisp-mode python-mode scheme-mode racket-mode rust-mode)))

  (setq +ligatures-in-modes
        (+appened-to-negation-list
         +ligatures-in-modes
         '(not emacs-lisp-mode scheme-mode racket-mode))))

(map! :leader
      (:when (modulep! :ui workspaces)
       :prefix ("TAB" . "workspace")
       :desc "Display tab bar"           "TAB" #'+workspace/display
       :desc "Switch workspace"          "."   #'+workspace/switch-to
       :desc "Switch to last workspace"  "$"   #'+workspace/other ;; Modified
       :desc "New workspace"             "n"   #'+workspace/new
       :desc "New named workspace"       "N"   #'+workspace/new-named
       :desc "Load workspace from file"  "l"   #'+workspace/load
       :desc "Save workspace to file"    "s"   #'+workspace/save
       :desc "Delete session"            "x"   #'+workspace/kill-session
       :desc "Delete this workspace"     "d"   #'+workspace/delete
       :desc "Rename workspace"          "r"   #'+workspace/rename
       :desc "Restore last session"      "R"   #'+workspace/restore-last-session
       :desc "Next workspace"            ">"   #'+workspace/switch-right ;; Modified
       :desc "Previous workspace"        "<"   #'+workspace/switch-left ;; Modified
       :desc "Switch to 1st workspace"   "1"   #'+workspace/switch-to-0
       :desc "Switch to 2nd workspace"   "2"   #'+workspace/switch-to-1
       :desc "Switch to 3rd workspace"   "3"   #'+workspace/switch-to-2
       :desc "Switch to 4th workspace"   "4"   #'+workspace/switch-to-3
       :desc "Switch to 5th workspace"   "5"   #'+workspace/switch-to-4
       :desc "Switch to 6th workspace"   "6"   #'+workspace/switch-to-5
       :desc "Switch to 7th workspace"   "7"   #'+workspace/switch-to-6
       :desc "Switch to 8th workspace"   "8"   #'+workspace/switch-to-7
       :desc "Switch to 9th workspace"   "9"   #'+workspace/switch-to-8
       :desc "Switch to final workspace" "0"   #'+workspace/switch-to-final))

(use-package! info-colors
  :commands (info-colors-fontify-node))

(add-hook 'Info-selection-hook 'info-colors-fontify-node)

(use-package! ag
  :commands (ag
             ag-files
             ag-regexp
             ag-project
             ag-project-files
             ag-project-regexp))

(after! pdf-tools
  ;; Auto install
  (pdf-tools-install-noverify)

  (setq-default pdf-view-image-relief 2
                pdf-view-display-size 'fit-page)

  (add-hook! 'pdf-view-mode-hook
    (when (memq doom-theme '(modus-vivendi doom-one doom-dark+ doom-vibrant))
      ;; TODO: find a more generic way to detect if we are in a dark theme
      (pdf-view-midnight-minor-mode 1)))

  ;; Color the background, so we can see the PDF page borders
  ;; https://protesilaos.com/emacs/modus-themes#h:ff69dfe1-29c0-447a-915c-b5ff7c5509cd
  (defun +pdf-tools-backdrop ()
    (face-remap-add-relative
     'default
     `(:background ,(if (memq doom-theme '(modus-vivendi modus-operandi))
                        (modus-themes-color 'bg-alt)
                      (doom-color 'bg-alt)))))

  (add-hook 'pdf-tools-enabled-hook #'+pdf-tools-backdrop))

(after! pdf-links
  ;; Tweak for Modus and `pdf-links'
  (when (memq doom-theme '(modus-vivendi modus-operandi))
    ;; https://protesilaos.com/emacs/modus-themes#h:2659d13e-b1a5-416c-9a89-7c3ce3a76574
    (let ((spec (apply #'append
                       (mapcar
                        (lambda (name)
                          (list name
                                (face-attribute 'pdf-links-read-link
                                                name nil 'default)))
                        '(:family :width :weight :slant)))))
      (setq pdf-links-read-link-convert-commands
            `("-density"    "96"
              "-family"     ,(plist-get spec :family)
              "-stretch"    ,(let* ((width (plist-get spec :width))
                                    (name (symbol-name width)))
                               (replace-regexp-in-string "-" ""
                                                         (capitalize name)))
              "-weight"     ,(pcase (plist-get spec :weight)
                               ('ultra-light "Thin")
                               ('extra-light "ExtraLight")
                               ('light       "Light")
                               ('semi-bold   "SemiBold")
                               ('bold        "Bold")
                               ('extra-bold  "ExtraBold")
                               ('ultra-bold  "Black")
                               (_weight      "Normal"))
              "-style"      ,(pcase (plist-get spec :slant)
                               ('italic  "Italic")
                               ('oblique "Oblique")
                               (_slant   "Normal"))
              "-pointsize"  "%P"
              "-undercolor" "%f"
              "-fill"       "%b"
              "-draw"       "text %X,%Y '%c'")))))

(after! spell-fu
  (defun +spell-fu-register-dictionary (lang)
    "Add `LANG` to spell-fu multi-dict, with a personal dictionary."
    ;; Add the dictionary
    (spell-fu-dictionary-add (spell-fu-get-ispell-dictionary lang))
    (let ((personal-dict-file (expand-file-name (format "aspell.%s.pws" lang) doom-user-dir)))
      ;; Create an empty personal dictionary if it doesn't exists
      (unless (file-exists-p personal-dict-file) (write-region "" nil personal-dict-file))
      ;; Add the personal dictionary
      (spell-fu-dictionary-add (spell-fu-get-personal-dictionary (format "%s-personal" lang) personal-dict-file))))

  (add-hook 'spell-fu-mode-hook
            (lambda ()
              (+spell-fu-register-dictionary +my/lang-main)
              (+spell-fu-register-dictionary +my/lang-secondary))))

(after! flycheck
  (flycheck-define-checker proselint
    "A linter for prose."
    :command ("proselint" source-inplace)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ": "
              (id (one-or-more (not (any " "))))
              (message) line-end))
    :modes (text-mode markdown-mode gfm-mode org-mode))

  ;; TODO: Can be enabled automatically for English documents using `guess-language'
  (defun +flycheck-proselint-toggle ()
    "Toggle Proselint checker for the current buffer."
    (interactive)
    (if (and (fboundp 'guess-language-buffer) (string= "en" (guess-language-buffer)))
        (if (memq 'proselint flycheck-checkers)
            (setq-local flycheck-checkers (delete 'proselint flycheck-checkers))
          (setq-local flycheck-checkers (append flycheck-checkers '(proselint))))
      (message "Proselint understands only English!"))))

(after! lsp-ltex
  (setq lsp-ltex-language "auto"
        lsp-ltex-mother-tongue +my/lang-mother-tongue
        flycheck-checker-error-threshold 1000)

  (advice-add
   '+lsp-ltex-setup :after
   (lambda ()
     (setq-local lsp-idle-delay 5.0
                 lsp-progress-function #'lsp-on-progress-legacy
                 lsp-progress-spinner-type 'half-circle
                 lsp-ui-sideline-show-code-actions nil
                 lsp-ui-sideline-show-diagnostics nil
                 lsp-ui-sideline-enable nil)))

  ;; FIXME
  (defun +lsp-ltex-check-document ()
    (interactive)
    (when-let ((file (buffer-file-name)))
      (let* ((uri (lsp--path-to-uri file))
             (beg (region-beginning))
             (end (region-end))
             (req (if (region-active-p)
                      `(:uri ,uri
                        :range ,(lsp--region-to-range beg end))
                    `(:uri ,uri))))
        (lsp-send-execute-command "_ltex.checkDocument" req)))))

(setq which-key-idle-delay 0.5 ;; Default is 1.0
      which-key-idle-secondary-delay 0.05) ;; Default is nil

(setq which-key-allow-multiple-replacements t)

(after! which-key
  (pushnew! which-key-replacement-alist
            '((""       . "\\`+?evil[-:]?\\(?:a-\\)?\\(.*\\)") . (nil . "🅔·\\1"))
            '(("\\`g s" . "\\`evilem--?motion-\\(.*\\)")       . (nil . "Ⓔ·\\1"))))

(setq company-global-modes
      '(not erc-mode
            circe-mode
            message-mode
            help-mode
            gud-mode
            vterm-mode
            ;;org-mode
            ))

(after! company-box
  (defun +company-box--reload-icons-h ()
    (setq company-box-icons-all-the-icons
          (let ((all-the-icons-scale-factor 0.8))
            `((Unknown       . ,(all-the-icons-faicon   "code"                 :face 'all-the-icons-purple))
              (Text          . ,(all-the-icons-material "text_fields"          :face 'all-the-icons-green))
              (Method        . ,(all-the-icons-faicon   "cube"                 :face 'all-the-icons-red))
              (Function      . ,(all-the-icons-faicon   "cube"                 :face 'all-the-icons-blue))
              (Constructor   . ,(all-the-icons-faicon   "cube"                 :face 'all-the-icons-blue-alt))
              (Field         . ,(all-the-icons-faicon   "tag"                  :face 'all-the-icons-red))
              (Variable      . ,(all-the-icons-material "adjust"               :face 'all-the-icons-blue))
              (Class         . ,(all-the-icons-material "class"                :face 'all-the-icons-red))
              (Interface     . ,(all-the-icons-material "tune"                 :face 'all-the-icons-red))
              (Module        . ,(all-the-icons-faicon   "cubes"                :face 'all-the-icons-red))
              (Property      . ,(all-the-icons-faicon   "wrench"               :face 'all-the-icons-red))
              (Unit          . ,(all-the-icons-material "straighten"           :face 'all-the-icons-red))
              (Value         . ,(all-the-icons-material "filter_1"             :face 'all-the-icons-red))
              (Enum          . ,(all-the-icons-material "plus_one"             :face 'all-the-icons-red))
              (Keyword       . ,(all-the-icons-material "filter_center_focus"  :face 'all-the-icons-red-alt))
              (Snippet       . ,(all-the-icons-faicon   "expand"               :face 'all-the-icons-red))
              (Color         . ,(all-the-icons-material "colorize"             :face 'all-the-icons-red))
              (File          . ,(all-the-icons-material "insert_drive_file"    :face 'all-the-icons-red))
              (Reference     . ,(all-the-icons-material "collections_bookmark" :face 'all-the-icons-red))
              (Folder        . ,(all-the-icons-material "folder"               :face 'all-the-icons-red-alt))
              (EnumMember    . ,(all-the-icons-material "people"               :face 'all-the-icons-red))
              (Constant      . ,(all-the-icons-material "pause_circle_filled"  :face 'all-the-icons-red))
              (Struct        . ,(all-the-icons-material "list"                 :face 'all-the-icons-red))
              (Event         . ,(all-the-icons-material "event"                :face 'all-the-icons-red))
              (Operator      . ,(all-the-icons-material "control_point"        :face 'all-the-icons-red))
              (TypeParameter . ,(all-the-icons-material "class"                :face 'all-the-icons-red))
              (Template      . ,(all-the-icons-material "settings_ethernet"    :face 'all-the-icons-green))
              (ElispFunction . ,(all-the-icons-faicon   "cube"                 :face 'all-the-icons-blue))
              (ElispVariable . ,(all-the-icons-material "adjust"               :face 'all-the-icons-blue))
              (ElispFeature  . ,(all-the-icons-material "stars"                :face 'all-the-icons-orange))
              (ElispFace     . ,(all-the-icons-material "format_paint"         :face 'all-the-icons-pink))))))

  (when (daemonp)
    ;; Replace Doom defined icons with mine
    (when (memq #'+company-box--load-all-the-icons server-after-make-frame-hook)
      (remove-hook 'server-after-make-frame-hook #'+company-box--load-all-the-icons))
    (add-hook 'server-after-make-frame-hook #'+company-box--reload-icons-h))

  ;; Reload icons even if not in Daemon mode
  (+company-box--reload-icons-h))

(after! treemacs
  (require 'dired)

  ;; My custom stuff (from tecosaur's config)
  (setq +treemacs-file-ignore-extensions
        '(;; LaTeX
          "aux" "ptc" "fdb_latexmk" "fls" "synctex.gz" "toc"
          ;; LaTeX - bibliography
          "bbl"
          ;; LaTeX - glossary
          "glg" "glo" "gls" "glsdefs" "ist" "acn" "acr" "alg"
          ;; LaTeX - pgfplots
          "mw"
          ;; LaTeX - pdfx
          "pdfa.xmpi"
          ;; Python
          "pyc"))

  (setq +treemacs-file-ignore-globs
        '(;; LaTeX
          "*/_minted-*"
          ;; AucTeX
          "*/.auctex-auto"
          "*/_region_.log"
          "*/_region_.tex"
          ;; Python
          "*/__pycache__"))

  ;; Reload treemacs theme
  (setq doom-themes-treemacs-enable-variable-pitch nil
        doom-themes-treemacs-theme "doom-colors")
  (doom-themes-treemacs-config)

  (setq treemacs-show-hidden-files nil
        treemacs-hide-dot-git-directory t
        treemacs-width 30)

  (defvar +treemacs-file-ignore-extensions '()
    "File extension which `treemacs-ignore-filter' will ensure are ignored")

  (defvar +treemacs-file-ignore-globs '()
    "Globs which will are transformed to `+treemacs-file-ignore-regexps' which `+treemacs-ignore-filter' will ensure are ignored")

  (defvar +treemacs-file-ignore-regexps '()
    "RegExps to be tested to ignore files, generated from `+treeemacs-file-ignore-globs'")

  (defun +treemacs-file-ignore-generate-regexps ()
    "Generate `+treemacs-file-ignore-regexps' from `+treemacs-file-ignore-globs'"
    (setq +treemacs-file-ignore-regexps (mapcar 'dired-glob-regexp +treemacs-file-ignore-globs)))

  (unless (equal +treemacs-file-ignore-globs '())
    (+treemacs-file-ignore-generate-regexps))

  (defun +treemacs-ignore-filter (file full-path)
    "Ignore files specified by `+treemacs-file-ignore-extensions', and `+treemacs-file-ignore-regexps'"
    (or (member (file-name-extension file) +treemacs-file-ignore-extensions)
        (let ((ignore-file nil))
          (dolist (regexp +treemacs-file-ignore-regexps ignore-file)
            (setq ignore-file (or ignore-file (if (string-match-p regexp full-path) t nil)))))))

  (add-to-list 'treemacs-ignored-file-predicates #'+treemacs-ignore-filter))

;; Run `M-x projectile-discover-projects-in-search-path' to reload paths from this variable
(setq projectile-project-search-path '("~/Areas/JSystem/PhD/papers"
                                       "~/Areas/JSystem/PhD/workspace"
                                       "~/Areas/JSystem/PhD/workspace-no"
                                       "~/Areas/JSystem/PhD/workspace-no/ez-wheel/swd-starter-kit-repo"
                                       ("~/myProjects/" . 2))) ;; ("dir" . depth)

(setq projectile-ignored-projects '("/tmp"
                                    "~/"
                                    "~/.cache"
                                    "~/.doom.d"
                                    "~/.config/doom"
                                    "~/.config/emacs"
                                    "~/.emacs.d"
                                    "~/.emacs.d/.local/straight/repos/"))

(setq +projectile-ignored-roots
      '("~/.cache"
        ;; No need for this one, as `doom-project-ignored-p' checks for files in `doom-local-dir'
        "~/.emacs.d/.local/straight/"))

(defun +projectile-ignored-project-function (filepath)
  "Return t if FILEPATH is within any of `+projectile-ignored-roots'"
  (require 'cl-lib)
  (or (doom-project-ignored-p filepath) ;; Used by default by doom with `projectile-ignored-project-function'
      (cl-some (lambda (root) (file-in-directory-p (expand-file-name filepath) (expand-file-name root)))
          +projectile-ignored-roots)))

(setq projectile-ignored-project-function #'+projectile-ignored-project-function)

(setq eros-eval-result-prefix "⟹ ")

(defun +dir-locals-reload-for-current-buffer ()
  "reload dir locals for the current buffer"
  (interactive)
  (let ((enable-local-variables :all))
    (hack-dir-local-variables-non-file-buffer)))

(defun +dir-locals-reload-for-all-buffers-in-this-directory ()
  "For every buffer with the same `default-directory` as the
current buffer's, reload dir-locals."
  (interactive)
  (let ((dir default-directory))
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (equal default-directory dir)
          (+dir-locals-reload-for-current-buffer))))))

(defun +dir-locals-enable-autoreload ()
  (when (and (buffer-file-name)
             (equal dir-locals-file (file-name-nondirectory (buffer-file-name))))
    (message "Dir-locals will be reloaded after saving.")
    (add-hook 'after-save-hook '+dir-locals-reload-for-all-buffers-in-this-directory nil t)))

(add-hook! '(emacs-lisp-mode-hook lisp-data-mode-hook) #'+dir-locals-enable-autoreload)

(after! eglot
  ;; A hack to make it works with projectile
  (defun projectile-project-find-function (dir)
    (let* ((root (projectile-project-root dir)))
      (and root (cons 'transient root))))

  (with-eval-after-load 'project
    (add-to-list 'project-find-functions 'projectile-project-find-function))

  ;; Use clangd with some options
  (set-eglot-client! 'c++-mode '("clangd" "-j=3" "--clang-tidy")))

(after! lsp-mode
  (setq lsp-idle-delay 1.0
        lsp-log-io nil
        gc-cons-threshold (* 1024 1024 100))) ;; 100MiB

(after! lsp-mode
  (setq lsp-lens-enable t
        lsp-semantic-tokens-enable t ;; hide unreachable ifdefs
        lsp-enable-symbol-highlighting t
        lsp-headerline-breadcrumb-enable nil
        ;; LSP UI related tweaks
        lsp-ui-sideline-enable nil
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-symbol nil
        lsp-ui-sideline-show-diagnostics nil
        lsp-ui-sideline-show-code-actions nil))

(after! lsp-clangd
  (setq lsp-clients-clangd-args
        '("-j=4"
          "--background-index"
          "--clang-tidy"
          "--completion-style=detailed"
          "--header-insertion=never"
          "--header-insertion-decorators=0"))
  (set-lsp-priority! 'clangd 1))

(after! tramp
  (when (require 'lsp-mode nil t)
    ;; (require 'lsp-pyright)

    (setq lsp-enable-snippet nil
          lsp-log-io nil
          ;; To bypass the "lsp--document-highlight fails if
          ;; textDocument/documentHighlight is not supported" error
          lsp-enable-symbol-highlighting nil)

    (lsp-register-client
     (make-lsp-client
      :new-connection (lsp-tramp-connection "pyls")
      :major-modes '(python-mode)
      :remote? t
      :server-id 'pyls-remote))))

(after! tramp
  (when (require 'lsp-mode nil t)

    (setq lsp-enable-snippet nil
          lsp-log-io nil
          ;; To bypass the "lsp--document-highlight fails if
          ;; textDocument/documentHighlight is not supported" error
          lsp-enable-symbol-highlighting nil)

    (lsp-register-client
     (make-lsp-client
      :new-connection
      (lsp-tramp-connection
       (lambda ()
         (cons "clangd-12" ; executable name on remote machine 'ccls'
               lsp-clients-clangd-args)))
      :major-modes '(c-mode c++-mode objc-mode cuda-mode)
      :remote? t
      :server-id 'clangd-remote))))

(use-package! vhdl-mode
  :when (and (modulep! :tools lsp) (not (modulep! :tools lsp +eglot)))
  :hook (vhdl-mode . #'+lsp-vhdl-ls-load)
  :init
  (defun +lsp-vhdl-ls-load ()
    (interactive)
    (lsp t)
    (flycheck-mode t))

  :config
  ;; Required unless vhdl_ls is on the $PATH
  (setq lsp-vhdl-server-path "~/Projects/foss/repos/rust_hdl/target/release/vhdl_ls"
        lsp-vhdl-server 'vhdl-ls
        lsp-vhdl--params nil)
  (require 'lsp-vhdl))

(use-package! maple-iedit
   :commands (maple-iedit-match-all maple-iedit-match-next maple-iedit-match-previous)
   :config
   (delete-selection-mode t)
   (setq maple-iedit-ignore-case t)
   (defhydra maple/iedit ()
     ("n" maple-iedit-match-next "next")
     ("t" maple-iedit-skip-and-match-next "skip and next")
     ("T" maple-iedit-skip-and-match-previous "skip and previous")
     ("p" maple-iedit-match-previous "prev"))
   :bind (:map evil-visual-state-map
          ("n" . maple/iedit/body)
          ("C-n" . maple-iedit-match-next)
          ("C-p" . maple-iedit-match-previous)
          ("C-t" . map-iedit-skip-and-match-next)
          ("C-T" . map-iedit-skip-and-match-previous)))

;; (use-package engine-mode
;;      :config
;;      (engine/set-keymap-prefix (kbd "C-c s"))
;;      (setq browse-url-browser-function 'browse-url-default-macosx-browser
;;            engine/browser-function 'browse-url-default-macosx-browser
;;            ;; browse-url-generic-program "google-chrome"
;;            )
;;      (defengine duckduckgo
;;        "https://duckduckgo.com/?q=%s"
;;        :keybinding "d")

;;      (defengine github
;;        "https://github.com/search?ref=simplesearch&q=%s"
;;        :keybinding "1")

;;      (defengine stack-overflow
;;        "https://stackoverflow.com/search?q=%s"
;;        :keybinding "s")

;;      (defengine npm
;;        "https://www.npmjs.com/search?q=%s"
;;        :keybinding "n")

;;      (defengine crates
;;        "https://crates.io/search?q=%s"
;;        :keybinding "c")

;;      (defengine localhost
;;        "http://localhost:%s"
;;        :keybinding "l")

;;      (defengine translate
;;        "https://translate.google.com/?sl=en&tl=vi&text=%s&op=translate"
;;        :keybinding "t")

;;      (defengine youtube
;;        "http://www.youtube.com/results?aq=f&oq=&search_query=%s"
;;        :keybinding "y")

;;      (defengine google
;;        "http://www.google.com/search?ie=utf-8&oe=utf-8&q=%s"
;;        :keybinding "g")

;;      (engine-mode 1))

;; (use-package bm
;;          :demand t

;;          :init
;;          ;; restore on load (even before you require bm)
;;          (setq bm-restore-repository-on-load t)


;;          :config
;;          ;; Allow cross-buffer 'next'
;;          (setq bm-cycle-all-buffers t)

;;          ;; where to store persistant files
;;          (setq bm-repository-file "~/.emacs.d/bm-repository")

;;          ;; save bookmarks
;;          (setq-default bm-buffer-persistence t)

;;          ;; Loading the repository from file when on start up.
;;          (add-hook 'after-init-hook 'bm-repository-load)

;;          ;; Saving bookmarks
;;          (add-hook 'kill-buffer-hook #'bm-buffer-save)

;;          ;; Saving the repository to file when on exit.
;;          ;; kill-buffer-hook is not called when Emacs is killed, so we
;;          ;; must save all bookmarks first.
;;          (add-hook 'kill-emacs-hook #'(lambda nil
;;                                           (bm-buffer-save-all)
;;                                           (bm-repository-save)))

;;          ;; The `after-save-hook' is not necessary to use to achieve persistence,
;;          ;; but it makes the bookmark data in repository more in sync with the file
;;          ;; state.
;;          (add-hook 'after-save-hook #'bm-buffer-save)

;;          ;; Restoring bookmarks
;;          (add-hook 'find-file-hooks   #'bm-buffer-restore)
;;          (add-hook 'after-revert-hook #'bm-buffer-restore)

;;          ;; The `after-revert-hook' is not necessary to use to achieve persistence,
;;          ;; but it makes the bookmark data in repository more in sync with the file
;;          ;; state. This hook might cause trouble when using packages
;;          ;; that automatically reverts the buffer (like vc after a check-in).
;;          ;; This can easily be avoided if the package provides a hook that is
;;          ;; called before the buffer is reverted (like `vc-before-checkin-hook').
;;          ;; Then new bookmarks can be saved before the buffer is reverted.
;;          ;; Make sure bookmarks is saved before check-in (and revert-buffer)
;;          (add-hook 'vc-before-checkin-hook #'bm-buffer-save)


;;          ;; key binding
;;          :bind (("C-s-0" . bm-toggle)
;;                 ("C-s-j" . bm-next)
;;                 ("C-s-k" . bm-previous)
;;                 ("C-s-s" . bm-show-all))
;;          )

(after! csv-mode
  ;; TODO: Need to fix the case of two commas, example "a,b,,c,d"
  (require 'cl-lib)
  (require 'color)

  (map! :localleader
        :map csv-mode-map
        "R" #'+csv-rainbow)

  (defun +csv-rainbow (&optional separator)
    (interactive (list (when current-prefix-arg (read-char "Separator: "))))
    (font-lock-mode 1)
    (let* ((separator (or separator ?\,))
           (n (count-matches (string separator) (point-at-bol) (point-at-eol)))
           (colors (cl-loop for i from 0 to 1.0 by (/ 2.0 n)
                            collect (apply #'color-rgb-to-hex
                                           (color-hsl-to-rgb i 0.3 0.5)))))
      (cl-loop for i from 2 to n by 2
               for c in colors
               for r = (format "^\\([^%c\n]+%c\\)\\{%d\\}" separator separator i)
               do (font-lock-add-keywords nil `((,r (1 '(face (:foreground ,c))))))))))

;; provide CSV mode setup
;; (add-hook 'csv-mode-hook (lambda () (+csv-rainbow)))

(use-package! elpy
  :hook ((elpy-mode . flycheck-mode)
         (elpy-mode . (lambda ()
                        (set (make-local-variable 'company-backends)
                             '((elpy-company-backend :with company-yasnippet))))))
  :config
  (elpy-enable))

(after! geiser
  (setq geiser-default-implementation 'guile
        geiser-chez-binary "chez-scheme")) ;; default is "scheme"

(after! code-review
  (setq code-review-auth-login-marker 'forge))

(after! magit
  ;; Disable if it causes performance issues
  (setq magit-diff-refine-hunk t))

(after! magit
  ;; Show gravatars
  (setq magit-revision-show-gravatars '("^Author:     " . "^Commit:     ")))

;; (use-package! magit-pretty-graph
;;   :after magit
;;   :init
;;   (setq magit-pg-command
;;         (concat "git --no-pager log"
;;                 " --topo-order --decorate=full"
;;                 " --pretty=format:\"%H%x00%P%x00%an%x00%ar%x00%s%x00%d\""
;;                 " -n 2000")) ;; Increase the default 100 limit

;;   (map! :localleader
;;         :map (magit-mode-map)
;;         :desc "Magit pretty graph" "p" (cmd! (magit-pg-repo (magit-toplevel)))))

(use-package! repo
  :commands repo-status)

(use-package! blamer
  :commands (blamer-mode)
  ;; :hook ((prog-mode . blamer-mode))
  :custom
  (blamer-idle-time 0.3)
  (blamer-min-offset 60)
  (blamer-prettify-time-p t)
  (blamer-entire-formatter "    %s")
  (blamer-author-formatter "Author %s ")
  (blamer-datetime-formatter "[%s], ")
  (blamer-commit-formatter "“%s”")
  :custom-face
  (blamer-face ((t :foreground "#7a88cf"
                   :background unspecified
                   :height 125
                   :italic t))))

(use-package! devdocs
  :commands (devdocs-lookup devdocs-install)
  :config
  (setq devdocs-data-dir (expand-file-name "devdocs" doom-data-dir)))

(use-package! pkgbuild-mode
  :commands (pkgbuild-mode)
  :mode "/PKGBUILD$")

(use-package! flycheck-projectile
  :commands flycheck-projectile-list-errors)

(use-package! graphviz-dot-mode
  :commands graphviz-dot-mode
  :mode ("\\.dot\\'" "\\.gv\\'")
  :init
  (after! org
    (setcdr (assoc "dot" org-src-lang-modes) 'graphviz-dot))

  :config
  (require 'company-graphviz-dot))

(use-package! mermaid-mode
  :commands mermaid-mode
  :mode "\\.mmd\\'")

(use-package! aas
  :commands aas-mode)

(after! lsp-java
  (setq lsp-java-java-path "/opt/homebrew/opt/openjdk@17/bin/java"
        lsp-java-configuration-runtimes
        '[(:name "JavaSE-17" :path "/opt/homebrew/opt/openjdk@17")]
        lsp-java-format-enabled t
        lsp-java-save-action-organize-imports t))

(use-package! org-roam
  :init
  (setq org-roam-directory org-directory
        org-roam-dailies-directory "Roam/journal/")
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ("C-c n r" . org-roam-node-random)
         ("C-c n j" . org-roam-dailies-capture-today))
  :config
  (org-roam-db-autosync-enable)
  (setq org-roam-completion-everywhere t
        org-roam-capture-templates
        '(("f" "Fleeting" plain "%?"
           :target (file+head "Roam/Capture/Fleeting/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %<%Y-%m-%d %a %H:%M>\n#+filetags: :fleeting:\n:PROPERTIES:\n:CREATED: %U\n:AREA: %^{Area|}\n:PROJECT: %^{Project|}\n:KEYWORDS: %^{Keywords|}\n:SOURCE: %^{Source|}\n:END:\n\n- Context :: %^{Context|}\n\n%?")
           :unnarrowed t)
          ("p" "Permanent" plain "%?"
           :target (file+head "Roam/Capture/Permanent/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %<%Y-%m-%d %a %H:%M>\n#+filetags: :permanent:\n:PROPERTIES:\n:CREATED: %U\n:AREA: %^{Area|}\n:PROJECT: %^{Project|}\n:KEYWORDS: %^{Keywords|}\n:SOURCE: %^{Source|}\n:REV_STAGE: %^{Stage|IDEA}\n:EXPORT_FILE_NAME: ${slug}\n:END:\n\n* Key Idea\n%?\n\n* Links\n")
           :unnarrowed t)
          ("l" "Literature" plain "%?"
           :target (file+head "Roam/Capture/Literature/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %<%Y-%m-%d %a %H:%M>\n#+filetags: :literature:\n:PROPERTIES:\n:CREATED: %U\n:AUTHOR: %^{Author}\n:SOURCE: %^{Source}\n:AREA: %^{Area|}\n:PROJECT: %^{Project|}\n:KEYWORDS: %^{Keywords|}\n:END:\n\n* Summary\n%?\n\n* Highlights\n")
           :unnarrowed t)
          ("m" "Meeting" plain "%?"
           :target (file+head "Roam/Capture/Meetings/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %<%Y-%m-%d %a %H:%M>\n#+filetags: :meeting:\n:PROPERTIES:\n:CREATED: %U\n:ATTENDEES: %^{Attendees}\n:AREA: %^{Area|}\n:PROJECT: %^{Project|}\n:KEYWORDS: %^{Keywords|}\n:END:\n\n* Context\n%?\n\n* Decisions\n\n* Next Actions\n")
           :unnarrowed t)
          ("r" "Resource" plain "%?"
           :target (file+head "Roam/Resources/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %<%Y-%m-%d %a %H:%M>\n#+filetags: :resource:\n:PROPERTIES:\n:CREATED: %U\n:SOURCE: %^{Source}\n:AUTHOR: %^{Author|}\n:AREA: %^{Area|}\n:PROJECT: %^{Project|}\n:KEYWORDS: %^{Keywords|}\n:NEXT_ACTION: %^{Next action|}\n:END:\n\n- Summary :: %^{Summary|}\n\n%?")
           :unnarrowed t)
          ("c" "Creation idea" plain "%?"
           :target (file+head "Roam/Creation/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %<%Y-%m-%d %a %H:%M>\n#+filetags: :creation:\n:PROPERTIES:\n:CREATED: %U\n:REV_STAGE: IDEA\n:AREA: %^{Area|}\n:PROJECT: %^{Project|}\n:KEYWORDS: %^{Keywords|}\n:EXPORT_FILE_NAME: ${slug}\n:END:\n\n* Problem\n%?\n\n* Outline\n\n* Assets\n")
           :unnarrowed t)))
  (setq org-roam-ref-capture-templates
        '(("w" "Web resource" plain "%?"
           :target (file+head "Roam/Resources/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %<%Y-%m-%d %a %H:%M>\n#+filetags: :resource:web:\n:PROPERTIES:\n:CREATED: %U\n:SOURCE: ${ref}\n:KEYWORDS: %^{Keywords|}\n:AREA: %^{Area|}\n:PROJECT: %^{Project|}\n:END:\n\n- Summary :: %^{Summary|}\n\n%?")
           :immediate-finish t
           :unnarrowed t)))
  (setq org-roam-node-display-template
        (concat "${title:80} " (propertize "${tags}" 'face 'org-tag))))

(defadvice! doom-modeline--buffer-file-name-roam-aware-a (orig-fun)
  :around #'doom-modeline-buffer-file-name ; takes no args
  (if (string-match-p (regexp-quote org-roam-directory) (or buffer-file-name ""))
      (replace-regexp-in-string
       "\\(?:^\\|.*/\\)\\([0-9]\\{4\\}\\)\\([0-9]\\{2\\}\\)\\([0-9]\\{2\\}\\)[0-9]*-"
       "🢔(\\1-\\2-\\3) "
       (subst-char-in-string ?_ ?  buffer-file-name))
    (funcall orig-fun)))

(use-package! websocket
  :after org-roam)

(use-package! org-roam-ui
  :after org-roam
  :commands org-roam-ui-open
  :hook (org-roam . org-roam-ui-mode)
  :config
  (require 'org-roam) ; in case autoloaded
  (defun org-roam-ui-open ()
    "Ensure the server is active, then open the roam graph."
    (interactive)
    (unless org-roam-ui-mode (org-roam-ui-mode 1))
    (browse-url (format "http://localhost:%d" org-roam-ui-port))))

(require 'editorconfig)
(editorconfig-mode 1)

(defun insert-my-dev-address ()
  "insert the my developement Address"
  (interactive)
  (insert "0x8b164927E4b449e42d5f82E93373Fd3bF4e5c49a")
  )

(defhydra jayden-launcher (:color blue :columns 3)
   "Launch"
   ("id" (insert-my-dev-address) "dev-address")
   ("ip" (insert-my-primary-address) "primary-address")
   ("b" (browse-url "https://jaydendang.com") "my-blog")
   ("gh" (browse-url "https://github.com/jayden-dang?tab=repositories") "GitHub")
   )

(use-package! ivy-posframe
  :after ivy
  :config
  (setq ivy-posframe-display-functions-alist
        '((swiper                     . ivy-posframe-display-at-point)
          (complete-symbol            . ivy-posframe-display-at-point)
          (counsel-M-x                . ivy-display-function-fallback)
          (counsel-esh-history        . ivy-posframe-display-at-window-center)
          (counsel-describe-function  . ivy-display-function-fallback)
          (counsel-describe-variable  . ivy-display-function-fallback)
          (counsel-find-file          . ivy-display-function-fallback)
          (counsel-recentf            . ivy-display-function-fallback)
          (counsel-register           . ivy-posframe-display-at-frame-bottom-window-center)
          (dmenu                      . ivy-posframe-display-at-frame-top-center)
          (nil                        . ivy-posframe-display)))
  (setq ivy-posframe-height-alist
        '((swiper . 20)
          (dmenu . 20)
          (t . 10)))
  (ivy-posframe-mode 1))

(map! :leader
      (:prefix ("v" . "Ivy")
       :desc "Ivy push view" "v p" #'ivy-push-view
       :desc "Ivy switch view" "v s" #'ivy-switch-view))

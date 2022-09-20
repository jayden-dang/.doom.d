;;; config.el -*- coding: utf-8-unix; lexical-binding: t; -*-

;; [[file:config.org::*System/User/Default information][System/User/Default information:1]]
;; global mode
(global-subword-mode 1)

;;
(setq user-full-name "Dang Quang Vu"
      user-mail-address "vugomars@gmail.com"

      ;; Split horizontally to right, vertically below the current window.
      evil-vsplit-window-right t
      evil-split-window-below t

      ;; Enable relative line number
      display-line-numbers-type 'relative

      source-directory (expand-file-name "~/.emacs.d/")


      )

(setq-default delete-by-moving-to-trash t ;; Delete files by moving them to trash.
              trash-directory nil

              ;; Take new window space from all other windows
              window-combination-resize t
              ;; stretch cursor to the glyph width
              x-stretch-cursor t



              )
;; System/User/Default information:1 ends here

;; [[file:config.org::*Common Variables][Common Variables:1]]
(defvar +my/lang-main          "en")
(defvar +my/lang-secondary     "cn")
(defvar +my/lang-mother-tongue "vn")

(defvar +my/biblio-libraries-list (list (expand-file-name "~/Zotero/library.bib")))
(defvar +my/biblio-storage-list   (list (expand-file-name "~/Zotero/storage/")))
(defvar +my/biblio-notes-path     (expand-file-name "~/Dropbox/PhD/bibliography/notes/"))
(defvar +my/biblio-styles-path    (expand-file-name "~/Zotero/styles/"))

;; Set it early, to avoid creating "~/org" at startup
(setq org-directory "~/Dropbox/Org")
;; Common Variables:1 ends here

;; [[file:config.org::*Show list of buffer when splitting][Show list of buffer when splitting:1]]
(defadvice! prompt-for-buffer (&rest _)
  :after '(evil-window-split evil-window-vsplit)
  (consult-buffer))
;; Show list of buffer when splitting:1 ends here

;; [[file:config.org::*Undo-fu][Undo-fu:1]]
;; Increase undo history limits even more
(after! undo-fu
  (setq undo-limit        10000000     ;; 1MB   (default is 160kB, Doom's default is 400kB)
        undo-strong-limit 100000000    ;; 100MB (default is 240kB, Doom's default is 3MB)
        undo-outer-limit  1000000000)) ;; 1GB   (default is 24MB,  Doom's default is 48MB)

(after! evil
  (setq evil-want-fine-undo t)) ;; By default while in insert all changes are one big blob
;; Undo-fu:1 ends here

;; [[file:config.org::*Visual undo (=vundo=)][Visual undo (=vundo=):2]]
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
;; Visual undo (=vundo=):2 ends here

;; [[file:config.org::*Messages buffer][Messages buffer:1]]
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
;; Messages buffer:1 ends here

;; [[file:config.org::*Secrets][Secrets:1]]
(setq auth-sources '("~/.authinfo.gpg")
      auth-source-do-cache t
      auth-source-cache-expiry 86400 ; All day, defaut is 2h (7200)
      password-cache t
      password-cache-expiry 86400)

(after! epa
  (setq-default epa-file-encrypt-to '("F2204E74F9D848C2")))
;; Secrets:1 ends here

;; [[file:config.org::*Initialization][Initialization:1]]
(defun +daemon-startup ()
  ;; mu4e
  (when (require 'mu4e nil t)
    ;; Automatically start `mu4e' in background.
    (when (load! "mu-lock.el" (expand-file-name "email/mu4e/autoload" doom-modules-dir) t)
      (setq +mu4e-lock-greedy t
            +mu4e-lock-relaxed t)
      (when (+mu4e-lock-available t)
        ;; Check each 5m, if `mu4e' if closed, start it in background.
        (run-at-time nil ;; Launch now
                     (* 60 5) ;; Check each 5 minutes
                     (lambda ()
                       (when (and (not (mu4e-running-p)) (+mu4e-lock-available))
                         (mu4e--start)
                         (message "Started `mu4e' in background.")))))))

  ;; RSS
  (when (require 'elfeed nil t)
    (run-at-time nil (* 2 60 60) #'elfeed-update))) ;; Check every 2h

(when (daemonp)
  ;; At daemon startup
  (add-hook 'emacs-startup-hook #'+daemon-startup)

  ;; After creating a new frame (via emacsclient)
  ;; Reload Doom's theme
  (add-hook 'server-after-make-frame-hook #'doom/reload-theme))
;; Initialization:1 ends here

;; [[file:config.org::*Save recent files][Save recent files:1]]
(when (daemonp)
  (add-hook! '(delete-frame-functions delete-terminal-functions)
    (let ((inhibit-message t))
      (recentf-save-list)
      (savehist-save))))
;; Save recent files:1 ends here

;; [[file:config.org::*Font][Font:1]]
(setq doom-font (font-spec :family "Iosevka Fixed Curly Slab" :size 15)
      doom-big-font (font-spec :family "Iosevka Fixed Curly Slab" :size 20 :weight 'light)
      doom-variable-pitch-font (font-spec :family "Iosevka Fixed Curly Slab")
      doom-unicode-font (font-spec :family "JuliaMono")
      doom-serif-font (font-spec :family "Iosevka Fixed Curly Slab" :weight 'light))
;; Font:1 ends here

;; [[file:config.org::*Doom][Doom:1]]
;; (setq doom-theme 'doom-one-light)
;; (remove-hook 'window-setup-hook #'doom-init-theme-h)
;; (add-hook 'after-init-hook #'doom-init-theme-h 'append)
;; Doom:1 ends here

;; [[file:config.org::*Modus themes][Modus themes:2]]
(use-package! modus-themes
  :init
  (setq modus-themes-hl-line '(accented intense)
        modus-themes-subtle-line-numbers t
        modus-themes-region '(bg-only no-extend) ;; accented
        modus-themes-variable-pitch-ui nil
        modus-themes-fringes 'subtle
        modus-themes-diffs nil
        modus-themes-italic-constructs t
        modus-themes-bold-constructs t
        modus-themes-intense-mouseovers t
        modus-themes-paren-match '(bold intense)
        modus-themes-syntax '(green-strings)
        modus-themes-links '(neutral-underline background)
        modus-themes-mode-line '(borderless padded)
        modus-themes-tabs-accented nil ;; default
        modus-themes-completions
        '((matches . (extrabold intense accented))
          (selection . (semibold accented intense))
          (popup . (accented)))
        modus-themes-headings '((1 . (rainbow 1.4))
                                (2 . (rainbow 1.3))
                                (3 . (rainbow 1.2))
                                (4 . (rainbow bold 1.1))
                                (t . (rainbow bold)))
        modus-themes-org-blocks 'gray-background
        modus-themes-org-agenda
        '((header-block . (semibold 1.4))
          (header-date . (workaholic bold-today 1.2))
          (event . (accented italic varied))
          (scheduled . rainbow)
          (habit . traffic-light))
        modus-themes-markup '(intense background)
        modus-themes-mail-citations 'intense
        modus-themes-lang-checkers '(background))

  (defun +modus-themes-tweak-packages ()
    (modus-themes-with-colors
      (set-face-attribute 'cursor nil :background (modus-themes-color 'blue))
      (set-face-attribute 'font-lock-type-face nil :foreground (modus-themes-color 'magenta-alt))
      (custom-set-faces
       ;; Tweak `evil-mc-mode'
       `(evil-mc-cursor-default-face ((,class :background ,magenta-intense-bg)))
       ;; Tweak `git-gutter-mode'
       `(git-gutter-fr:added ((,class :foreground ,green-fringe-bg)))
       `(git-gutter-fr:deleted ((,class :foreground ,red-fringe-bg)))
       `(git-gutter-fr:modified ((,class :foreground ,yellow-fringe-bg)))
       ;; Tweak `doom-modeline'
       `(doom-modeline-evil-normal-state ((,class :foreground ,green-alt-other)))
       `(doom-modeline-evil-insert-state ((,class :foreground ,red-alt-other)))
       `(doom-modeline-evil-visual-state ((,class :foreground ,magenta-alt)))
       `(doom-modeline-evil-operator-state ((,class :foreground ,blue-alt)))
       `(doom-modeline-evil-motion-state ((,class :foreground ,blue-alt-other)))
       `(doom-modeline-evil-replace-state ((,class :foreground ,yellow-alt)))
       ;; Tweak `diff-hl-mode'
       `(diff-hl-insert ((,class :foreground ,green-fringe-bg)))
       `(diff-hl-delete ((,class :foreground ,red-fringe-bg)))
       `(diff-hl-change ((,class :foreground ,yellow-fringe-bg)))
       ;; Tweak `solaire-mode'
       `(solaire-default-face ((,class :inherit default :background ,bg-alt :foreground ,fg-dim)))
       `(solaire-line-number-face ((,class :inherit solaire-default-face :foreground ,fg-unfocused)))
       `(solaire-hl-line-face ((,class :background ,bg-active)))
       `(solaire-org-hide-face ((,class :background ,bg-alt :foreground ,bg-alt)))
       ;; Tweak `display-fill-column-indicator-mode'
       `(fill-column-indicator ((,class :height 0.3 :background ,bg-inactive :foreground ,bg-inactive)))
       ;; Tweak `mmm-mode'
       `(mmm-cleanup-submode-face ((,class :background ,yellow-refine-bg)))
       `(mmm-code-submode-face ((,class :background ,bg-active)))
       `(mmm-comment-submode-face ((,class :background ,blue-refine-bg)))
       `(mmm-declaration-submode-face ((,class :background ,cyan-refine-bg)))
       `(mmm-default-submode-face ((,class :background ,bg-alt)))
       `(mmm-init-submode-face ((,class :background ,magenta-refine-bg)))
       `(mmm-output-submode-face ((,class :background ,red-refine-bg)))
       `(mmm-special-submode-face ((,class :background ,green-refine-bg))))))

  (add-hook 'modus-themes-after-load-theme-hook #'+modus-themes-tweak-packages)

  :config
  (modus-themes-load-operandi)
  (map! :leader
        :prefix "t" ;; toggle
        :desc "Toggle Modus theme" "m" #'modus-themes-toggle))
;; Modus themes:2 ends here

;; [[file:config.org::*Clock][Clock:1]]
(after! doom-modeline
  (setq display-time-string-forms
        '((propertize (concat " 🕘 " 24-hours ":" minutes))))
  (display-time-mode 1) ; Enable time in the mode-line

  ;; Add padding to the right
  (doom-modeline-def-modeline 'main
   '(bar workspace-name window-number modals matches follow buffer-info remote-host buffer-position word-count parrot selection-info)
   '(objed-state misc-info persp-name battery grip irc mu4e gnus github debug repl lsp minor-modes input-method indent-info buffer-encoding major-mode process vcs checker "   ")))
;; Clock:1 ends here

;; [[file:config.org::*Battery][Battery:1]]
(after! doom-modeline
  (let ((battery-str (battery)))
    (unless (or (equal "Battery status not available" battery-str)
                (string-match-p (regexp-quote "unknown") battery-str)
                (string-match-p (regexp-quote "N/A") battery-str))
      (display-battery-mode 1))))
;; Battery:1 ends here

;; [[file:config.org::*Mode line customization][Mode line customization:1]]
(after! doom-modeline
  (setq doom-modeline-bar-width 4
        doom-modeline-mu4e t
        doom-modeline-major-mode-icon t
        doom-modeline-major-mode-color-icon t
        doom-modeline-buffer-file-name-style 'truncate-upto-project))
;; Mode line customization:1 ends here

;; [[file:config.org::*Set transparency & Full Screen][Set transparency & Full Screen:1]]
;; set transparent
(set-frame-parameter (selected-frame) 'alpha '(97 100))
(add-to-list 'default-frame-alist '(alpha 97 100))

;; full screen
(add-to-list 'initial-frame-alist '(fullscreen . maximized))
(add-hook 'org-mode-hook 'turn-on-auto-fill)
;; Set transparency & Full Screen:1 ends here

;; [[file:config.org::*Custom splash image][Custom splash image:1]]
(setq fancy-splash-image (expand-file-name "assets/doom-emacs-gray.svg" doom-user-dir))
;; Custom splash image:1 ends here

;; [[file:config.org::*Dashboard][Dashboard:1]]
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-footer)
(add-hook! '+doom-dashboard-mode-hook (hl-line-mode -1))
(setq-hook! '+doom-dashboard-mode-hook evil-normal-state-cursor (list nil))
;; Dashboard:1 ends here

;; [[file:config.org::*SVG tag and =svg-lib=][SVG tag and =svg-lib=:2]]
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
;; SVG tag and =svg-lib=:2 ends here

;; [[file:config.org::*SVG tag and =svg-lib=][SVG tag and =svg-lib=:3]]
(after! svg-lib
  ;; Set `svg-lib' cache directory
  (setq svg-lib-icons-dir (expand-file-name "svg-lib" doom-data-dir)))
;; SVG tag and =svg-lib=:3 ends here

;; [[file:config.org::*Focus][Focus:2]]
(use-package! focus
  :commands focus-mode)
;; Focus:2 ends here

;; [[file:config.org::*Scrolling][Scrolling:2]]
(use-package! good-scroll
  :unless EMACS29+
  :config (good-scroll-mode 1))

(when EMACS29+
  (pixel-scroll-precision-mode 1))

(setq hscroll-step 1
      hscroll-margin 0
      scroll-step 1
      scroll-margin 0
      scroll-conservatively 101
      scroll-up-aggressively 0.01
      scroll-down-aggressively 0.01
      scroll-preserve-screen-position 'always
      auto-window-vscroll nil
      fast-but-imprecise-scrolling nil)
;; Scrolling:2 ends here

;; [[file:config.org::*All the icons][All the icons:1]]
(after! all-the-icons
  (setcdr (assoc "m" all-the-icons-extension-icon-alist)
          (cdr (assoc "matlab" all-the-icons-extension-icon-alist))))
;; All the icons:1 ends here

;; [[file:config.org::*Tabs][Tabs:1]]
(after! centaur-tabs
  ;; For some reason, setting `centaur-tabs-set-bar' this to `right'
  ;; instead of Doom's default `left', fixes this issue with Emacs daemon:
  ;; https://github.com/doomemacs/doomemacs/issues/6647#issuecomment-1229365473
  (setq centaur-tabs-set-bar 'right
        centaur-tabs-gray-out-icons 'buffer
        centaur-tabs-set-modified-marker t
        centaur-tabs-close-button "⨂"
        centaur-tabs-modified-marker "⨀"))
;; Tabs:1 ends here

;; [[file:config.org::*Zen (writeroom) mode][Zen (writeroom) mode:1]]
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
;; Zen (writeroom) mode:1 ends here

;; [[file:config.org::*Highlight indent guides][Highlight indent guides:1]]
(after! highlight-indent-guides
  (setq highlight-indent-guides-character ?│
        highlight-indent-guides-responsive 'top))
;; Highlight indent guides:1 ends here

;; [[file:config.org::*File templates][File templates:1]]
(set-file-template! "\\.tex$" :trigger "__" :mode 'latex-mode)
(set-file-template! "\\.org$" :trigger "__" :mode 'org-mode)
(set-file-template! "/LICEN[CS]E$" :trigger '+file-templates/insert-license)
;; File templates:1 ends here

;; [[file:config.org::*Scratch buffer][Scratch buffer:1]]
(setq doom-scratch-initial-major-mode 'emacs-lisp-mode)
;; Scratch buffer:1 ends here

;; [[file:config.org::*Very large files][Very large files:2]]
(use-package! vlf-setup
  :defer-incrementally vlf-tune vlf-base vlf-write vlf-search vlf-occur vlf-follow vlf-ediff vlf)
;; Very large files:2 ends here

;; [[file:config.org::*Evil][Evil:1]]
(after! evil
  ;; This fixes https://github.com/doomemacs/doomemacs/issues/6478
  ;; Ref: https://github.com/emacs-evil/evil/issues/1630
  (evil-select-search-module 'evil-search-module 'isearch)

  (setq evil-kill-on-visual-paste nil)) ; Don't put overwritten text in the kill ring
;; Evil:1 ends here

;; [[file:config.org::*Aggressive indent][Aggressive indent:2]]
(use-package! aggressive-indent
  :commands (aggressive-indent-mode))
;; Aggressive indent:2 ends here

;; [[file:config.org::*YASnippet][YASnippet:1]]
(setq yas-triggers-in-field t)
;; YASnippet:1 ends here

;; [[file:config.org::*Emojify][Emojify:1]]
(setq emojify-emoji-set "twemoji-v2")
;; Emojify:1 ends here

;; [[file:config.org::*Emojify][Emojify:2]]
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
;; Emojify:2 ends here

;; [[file:config.org::*Emojify][Emojify:3]]
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
;; Emojify:3 ends here

;; [[file:config.org::*Emojify][Emojify:4]]
(add-hook! '(mu4e-compose-mode org-msg-edit-mode circe-channel-mode) (emoticon-to-emoji 1))
;; Emojify:4 ends here

;; [[file:config.org::*Ligatures][Ligatures:1]]
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
;; Ligatures:1 ends here

;; [[file:config.org::*Spell-Fu][Spell-Fu:1]]
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
;; Spell-Fu:1 ends here

;; [[file:config.org::*Proselint][Proselint:1]]
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
;; Proselint:1 ends here

;; [[file:config.org::*Grammarly][Grammarly:2]]
(use-package! grammarly
  :config
  (grammarly-load-from-authinfo))
;; Grammarly:2 ends here

;; [[file:config.org::*Eglot][Eglot:2]]
(use-package! eglot-grammarly
  :commands (+lsp-grammarly-load)
  :init
  (defun +lsp-grammarly-load ()
    "Load Grammarly LSP server for Eglot."
    (interactive)
    (require 'eglot-grammarly)
    (call-interactively #'eglot)))
;; Eglot:2 ends here

;; [[file:config.org::*LSP Mode][LSP Mode:2]]
(use-package! lsp-grammarly
  :commands (+lsp-grammarly-load +lsp-grammarly-toggle)
  :init
  (defun +lsp-grammarly-load ()
    "Load Grammarly LSP server for LSP Mode."
    (interactive)
    (require 'lsp-grammarly)
    (lsp-deferred)) ;; or (lsp)

  (defun +lsp-grammarly-enabled-p ()
    (not (member 'grammarly-ls lsp-disabled-clients)))

  (defun +lsp-grammarly-enable ()
    "Enable Grammarly LSP."
    (interactive)
    (when (not (+lsp-grammarly-enabled-p))
      (setq lsp-disabled-clients (remove 'grammarly-ls lsp-disabled-clients))
      (message "Enabled grammarly-ls"))
    (+lsp-grammarly-load))

  (defun +lsp-grammarly-disable ()
    "Disable Grammarly LSP."
    (interactive)
    (when (+lsp-grammarly-enabled-p)
      (add-to-list 'lsp-disabled-clients 'grammarly-ls)
      (lsp-disconnect)
      (message "Disabled grammarly-ls")))

  (defun +lsp-grammarly-toggle ()
    "Enable/disable Grammarly LSP."
    (interactive)
    (if (+lsp-grammarly-enabled-p)
        (+lsp-grammarly-disable)
      (+lsp-grammarly-enable)))

  (after! lsp-mode
    ;; Disable by default
    (add-to-list 'lsp-disabled-clients 'grammarly-ls))

  :config
  (set-lsp-priority! 'grammarly-ls 1))
;; LSP Mode:2 ends here

;; [[file:config.org::*Grammalecte][Grammalecte:2]]
(use-package! flycheck-grammalecte
  :when nil ;; BUG: Disabled, there is a Python error
  :commands (flycheck-grammalecte-correct-error-at-point
             grammalecte-conjugate-verb
             grammalecte-define
             grammalecte-define-at-point
             grammalecte-find-synonyms
             grammalecte-find-synonyms-at-point)
  :init
  (setq grammalecte-settings-file (expand-file-name "grammalecte/grammalecte-cache.el" doom-data-dir)
        grammalecte-python-package-directory (expand-file-name "grammalecte/grammalecte" doom-data-dir))

  (setq flycheck-grammalecte-report-spellcheck t
        flycheck-grammalecte-report-grammar t
        flycheck-grammalecte-report-apos nil
        flycheck-grammalecte-report-esp nil
        flycheck-grammalecte-report-nbsp nil
        flycheck-grammalecte-filters
        '("(?m)^# ?-*-.+$"
          ;; Ignore LaTeX equations (inline and block)
          "\\$.*?\\$"
          "(?s)\\\\begin{\\(?1:\\(?:equation.\\|align.\\)\\)}.*?\\\\end{\\1}"))

  (map! :leader :prefix ("l" . "custom")
        (:prefix ("g" . "grammalecte")
         :desc "Correct error at point"     "p" #'flycheck-grammalecte-correct-error-at-point
         :desc "Conjugate a verb"           "V" #'grammalecte-conjugate-verb
         :desc "Define a word"              "W" #'grammalecte-define
         :desc "Conjugate a verb at point"  "w" #'grammalecte-define-at-point
         :desc "Find synonyms"              "S" #'grammalecte-find-synonyms
         :desc "Find synonyms at point"     "s" #'grammalecte-find-synonyms-at-point))

  :config
  (grammalecte-download-grammalecte)
  (flycheck-grammalecte-setup))
;; Grammalecte:2 ends here

;; [[file:config.org::*LTeX/LanguageTool][LTeX/LanguageTool:1]]
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
;; LTeX/LanguageTool:1 ends here

;; [[file:config.org::*Go Translate (Google, Bing and DeepL)][Go Translate (Google, Bing and DeepL):2]]
(use-package! go-translate
  :commands (gts-do-translate
             +gts-yank-translated-region
             +gts-translate-with)
  :init
  ;; Your languages pairs
  (setq gts-translate-list (list (list +my/lang-main +my/lang-secondary)
                                 (list +my/lang-main +my/lang-mother-tongue)
                                 (list +my/lang-secondary +my/lang-mother-tongue)
                                 (list +my/lang-secondary +my/lang-main)))

  (map! :localleader
        :map (org-mode-map markdown-mode-map latex-mode-map text-mode-map)
        :desc "Yank translated region" "R" #'+gts-yank-translated-region)

  (map! :leader :prefix "l"
        (:prefix ("G" . "go-translate")
         :desc "Bing"                   "b" (lambda () (interactive) (+gts-translate-with 'bing))
         :desc "DeepL"                  "d" (lambda () (interactive) (+gts-translate-with 'deepl))
         :desc "Google"                 "g" (lambda () (interactive) (+gts-translate-with))
         :desc "Yank translated region" "R" #'+gts-yank-translated-region
         :desc "gts-do-translate"       "t" #'gts-do-translate))

  :config
  ;; Config the default translator, which will be used by the command `gts-do-translate'
  (setq gts-default-translator
        (gts-translator
         ;; Used to pick source text, from, to. choose one.
         :picker (gts-prompt-picker)
         ;; One or more engines, provide a parser to give different output.
         :engines (gts-google-engine :parser (gts-google-summary-parser))
         ;; Render, only one, used to consumer the output result.
         :render (gts-buffer-render)))

  ;; Custom texter which remove newlines in the same paragraph
  (defclass +gts-translate-paragraph (gts-texter) ())

  (cl-defmethod gts-text ((_ +gts-translate-paragraph))
    (when (use-region-p)
      (let ((text (buffer-substring-no-properties (region-beginning) (region-end))))
        (with-temp-buffer
          (insert text)
          (goto-char (point-min))
          (let ((case-fold-search nil))
            (while (re-search-forward "\n[^\n]" nil t)
              (replace-region-contents
               (- (point) 2) (- (point) 1)
               (lambda (&optional a b) " ")))
            (buffer-string))))))

  ;; Custom picker to use the paragraph texter
  (defclass +gts-paragraph-picker (gts-picker)
    ((texter :initarg :texter :initform (+gts-translate-paragraph))))

  (cl-defmethod gts-pick ((o +gts-paragraph-picker))
    (let ((text (gts-text (oref o texter))))
      (when (or (null text) (zerop (length text)))
        (user-error "Make sure there is any word at point, or selection exists"))
      (let ((path (gts-path o text)))
        (setq gts-picker-current-path path)
        (cl-values text path))))

  (defun +gts-yank-translated-region ()
    (interactive)
    (gts-translate
     (gts-translator
      :picker (+gts-paragraph-picker)
      :engines (gts-google-engine)
      :render (gts-kill-ring-render))))

  (defun +gts-translate-with (&optional engine)
    (interactive)
    (gts-translate
     (gts-translator
      :picker (+gts-paragraph-picker)
      :engines
      (cond ((eq engine 'deepl)
             (gts-deepl-engine
              :auth-key ;; Get API key from ~/.authinfo.gpg (machine api-free.deepl.com)
              (funcall
               (plist-get (car (auth-source-search :host "api-free.deepl.com" :max 1))
                          :secret))
              :pro nil))
            ((eq engine 'bing) (gts-bing-engine))
            (t (gts-google-engine)))
      :render (gts-buffer-render)))))
;; Go Translate (Google, Bing and DeepL):2 ends here

;; [[file:config.org::*Offline dictionaries][Offline dictionaries:2]]
(use-package! lexic
  :commands (lexic-search lexic-list-dictionary)
  :config
  (map! :map lexic-mode-map
        :n "q" #'lexic-return-from-lexic
        :nv "RET" #'lexic-search-word-at-point
        :n "a" #'outline-show-all
        :n "h" (cmd! (outline-hide-sublevels 3))
        :n "o" #'lexic-toggle-entry
        :n "n" #'lexic-next-entry
        :n "N" (cmd! (lexic-next-entry t))
        :n "p" #'lexic-previous-entry
        :n "P" (cmd! (lexic-previous-entry t))
        :n "E" (cmd! (lexic-return-from-lexic) ; expand
                     (switch-to-buffer (lexic-get-buffer)))
        :n "M" (cmd! (lexic-return-from-lexic) ; minimise
                     (lexic-goto-lexic))
        :n "C-p" #'lexic-search-history-backwards
        :n "C-n" #'lexic-search-history-forwards
        :n "/" (cmd! (call-interactively #'lexic-search))))
;; Offline dictionaries:2 ends here

;; [[file:config.org::*Workspaces][Workspaces:1]]
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
;; Workspaces:1 ends here

;; [[file:config.org::*Info colors][Info colors:2]]
(use-package! info-colors
  :commands (info-colors-fontify-node))

(add-hook 'Info-selection-hook 'info-colors-fontify-node)
;; Info colors:2 ends here

;; [[file:config.org::*The Silver Searcher][The Silver Searcher:2]]
(use-package! ag
  :when AG-P
  :commands (ag
             ag-files
             ag-regexp
             ag-project
             ag-project-files
             ag-project-regexp))
;; The Silver Searcher:2 ends here

;; [[file:config.org::*Page break lines][Page break lines:2]]
(use-package! page-break-lines
  :diminish
  :init (global-page-break-lines-mode))
;; Page break lines:2 ends here

;; [[file:config.org::*PDF tools][PDF tools:1]]
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
;; PDF tools:1 ends here

;; [[file:config.org::*Which key][Which key:1]]
(setq which-key-idle-delay 0.5 ;; Default is 1.0
      which-key-idle-secondary-delay 0.05) ;; Default is nil
;; Which key:1 ends here

;; [[file:config.org::*Which key][Which key:2]]
(setq which-key-allow-multiple-replacements t)

(after! which-key
  (pushnew! which-key-replacement-alist
            '((""       . "\\`+?evil[-:]?\\(?:a-\\)?\\(.*\\)") . (nil . "🅔·\\1"))
            '(("\\`g s" . "\\`evilem--?motion-\\(.*\\)")       . (nil . "Ⓔ·\\1"))))
;; Which key:2 ends here

;; [[file:config.org::*Disabled for some mode][Disabled for some mode:1]]
(setq company-global-modes
      '(not erc-mode
            circe-mode
            message-mode
            help-mode
            gud-mode
            vterm-mode
            org-mode))
;; Disabled for some mode:1 ends here

;; [[file:config.org::*Tweak =company-box=][Tweak =company-box=:1]]
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
;; Tweak =company-box=:1 ends here

;; [[file:config.org::*Treemacs][Treemacs:1]]
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
;; Treemacs:1 ends here

;; [[file:config.org::*Projectile][Projectile:1]]
;; Run `M-x projectile-discover-projects-in-search-path' to reload paths from this variable
(setq projectile-project-search-path
      '("~/Dropbox/PhD/papers"
        "~/Dropbox/PhD/workspace"
        "~/Dropbox/PhD/workspace-no"
        "~/Dropbox/PhD/workspace-no/ez-wheel/swd-starter-kit-repo"
        ("~/myProjects/" . 2))) ;; ("dir" . depth)

(setq projectile-ignored-projects
      '("/tmp"
        "~/"
        "~/.cache"
        "~/.doom.d"
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
;; Projectile:1 ends here

;; [[file:config.org::*Tramp][Tramp:1]]
(after! tramp
  (setenv "SHELL" "/bin/bash")
  (setq tramp-shell-prompt-pattern "\\(?:^\\|\\)[^]#$%>\n]*#?[]#$%>] *\\(\\[[0-9;]*[a-zA-Z] *\\)*")) ;; default + 
;; Tramp:1 ends here

;; [[file:config.org::*Eros-eval][Eros-eval:1]]
(setq eros-eval-result-prefix "⟹ ")
;; Eros-eval:1 ends here

;; [[file:config.org::*=dir-locals.el=][=dir-locals.el=:1]]
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
;; =dir-locals.el=:1 ends here

;; [[file:config.org::*Erefactor][Erefactor:2]]
(use-package! erefactor
  :defer t)
;; Erefactor:2 ends here

;; [[file:config.org::*Lorem ipsum][Lorem ipsum:2]]
(use-package! lorem-ipsum
  :commands (lorem-ipsum-insert-sentences
             lorem-ipsum-insert-paragraphs
             lorem-ipsum-insert-list))
;; Lorem ipsum:2 ends here

;; [[file:config.org::*Eglot][Eglot:1]]
(after! eglot
  ;; A hack to make it works with projectile
  (defun projectile-project-find-function (dir)
    (let* ((root (projectile-project-root dir)))
      (and root (cons 'transient root))))

  (with-eval-after-load 'project
    (add-to-list 'project-find-functions 'projectile-project-find-function))

  ;; Use clangd with some options
  (set-eglot-client! 'c++-mode '("clangd" "-j=3" "--clang-tidy")))
;; Eglot:1 ends here

;; [[file:config.org::*Performance][Performance:1]]
(after! lsp-mode
  (setq lsp-idle-delay 1.0
        lsp-log-io nil
        gc-cons-threshold (* 1024 1024 100))) ;; 100MiB
;; Performance:1 ends here

;; [[file:config.org::*Features & UI][Features & UI:1]]
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
;; Features & UI:1 ends here

;; [[file:config.org::*LSP mode with =clangd=][LSP mode with =clangd=:1]]
(after! lsp-clangd
  (setq lsp-clients-clangd-args
        '("-j=4"
          "--background-index"
          "--clang-tidy"
          "--completion-style=detailed"
          "--header-insertion=never"
          "--header-insertion-decorators=0"))
  (set-lsp-priority! 'clangd 1))
;; LSP mode with =clangd=:1 ends here

;; [[file:config.org::*Python][Python:1]]
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
;; Python:1 ends here

;; [[file:config.org::*C/C++ with =clangd=][C/C++ with =clangd=:1]]
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
;; C/C++ with =clangd=:1 ends here

;; [[file:config.org::*VHDL][VHDL:1]]
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
;; VHDL:1 ends here

;; [[file:config.org::*SonarLint][SonarLint:2]]
(use-package! lsp-sonarlint)
;; SonarLint:2 ends here

;; [[file:config.org::*Cppcheck][Cppcheck:1]]
(after! flycheck
  (setq flycheck-cppcheck-checks '("information"
                                   "missingInclude"
                                   "performance"
                                   "portability"
                                   "style"
                                   "unusedFunction"
                                   "warning"))) ;; Actually, we can use "all"
;; Cppcheck:1 ends here

;; [[file:config.org::*Project CMake][Project CMake:2]]
(use-package! project-cmake
    :config
    (require 'eglot)
    (project-cmake-scan-kits)
    (project-cmake-eglot-integration))
;; Project CMake:2 ends here

;; [[file:config.org::*Clang-format][Clang-format:2]]
(use-package! clang-format
  :when CLANG-FORMAT-P
  :commands (clang-format-region))
;; Clang-format:2 ends here

;; [[file:config.org::*Auto-include C++ headers][Auto-include C++ headers:2]]
(use-package! cpp-auto-include
  :commands cpp-auto-include)
;; Auto-include C++ headers:2 ends here

;; [[file:config.org::*C/C++ preprocessor conditions][C/C++ preprocessor conditions:1]]
(unless (modulep! :lang cc +lsp) ;; Disable if LSP for C/C++ is enabled
  (use-package! hideif
    :hook (c-mode . hide-ifdef-mode)
    :hook (c++-mode . hide-ifdef-mode)
    :init
    (setq hide-ifdef-shadow t
          hide-ifdef-initially t)))
;; C/C++ preprocessor conditions:1 ends here

;; [[file:config.org::*DAP][DAP:2]]
(after! dap-mode
  ;; Set latest versions
  (setq dap-cpptools-extension-version "1.11.5")
  (require 'dap-cpptools)

  (setq dap-codelldb-extension-version "1.7.4")
  (require 'dap-codelldb)

  (setq dap-gdb-lldb-extension-version "0.26.0")
  (require 'dap-gdb-lldb)

  ;; More minimal UI
  (setq dap-auto-configure-features '(breakpoints locals expressions tooltip)
        dap-auto-show-output nil ;; Hide the annoying server output
        lsp-enable-dap-auto-configure t)

  ;; Automatically trigger dap-hydra when a program hits a breakpoint.
  (add-hook 'dap-stopped-hook (lambda (arg) (call-interactively #'dap-hydra)))

  ;; Automatically delete session and close dap-hydra when DAP is terminated.
  (add-hook 'dap-terminated-hook
            (lambda (arg)
              (call-interactively #'dap-delete-session)
              (dap-hydra/nil)))

  ;; A workaround to correctly show breakpoints
  ;; from: https://github.com/emacs-lsp/dap-mode/issues/374#issuecomment-1140399819
  (add-hook! +dap-running-session-mode
    (set-window-buffer nil (current-buffer))))
;; DAP:2 ends here

;; [[file:config.org::*Doom store][Doom store:1]]
(defun +debugger/clear-last-session ()
  "Clear the last stored session"
  (interactive)
  (doom-store-clear "+debugger"))

(map! :leader :prefix ("l" . "custom")
      (:when (modulep! :tools debugger +lsp)
       :prefix ("d" . "debugger")
       :desc "Clear last DAP session" "c" #'+debugger/clear-last-session))
;; Doom store:1 ends here

;; [[file:config.org::*Maxima][Maxima:2]]
(use-package! maxima
  :when MAXIMA-P
  :commands (maxima-mode maxima-inferior-mode maxima)
  :init
  (require 'straight) ;; to use `straight-build-dir' and `straight-base-dir'
  (setq maxima-font-lock-keywords-directory ;; a workaround to undo the straight workaround!
        (expand-file-name (format "straight/%s/maxima/keywords" straight-build-dir) straight-base-dir))

  ;; The `maxima-hook-function' setup `company-maxima'.
  (add-hook 'maxima-mode-hook #'maxima-hook-function)
  (add-hook 'maxima-inferior-mode-hook #'maxima-hook-function)
  (add-to-list 'auto-mode-alist '("\\.ma[cx]\\'" . maxima-mode)))
;; Maxima:2 ends here

;; [[file:config.org::*IMaxima][IMaxima:2]]
(use-package! imaxima
  :when MAXIMA-P
  :commands (imaxima imath-mode)
  :init
  (setq imaxima-use-maxima-mode-flag nil ;; otherwise, it don't render equations with LaTeX.
        imaxima-scale-factor 2.0)

  ;; Hook the `maxima-inferior-mode' to get Company completion.
  (add-hook 'imaxima-startup-hook #'maxima-inferior-mode))
;; IMaxima:2 ends here

;; [[file:config.org::*CSV rainbow][CSV rainbow:1]]
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
;; CSV rainbow:1 ends here

;; [[file:config.org::*Python IDE][Python IDE:2]]
(use-package! elpy
  :hook ((elpy-mode . flycheck-mode)
         (elpy-mode . (lambda ()
                        (set (make-local-variable 'company-backends)
                             '((elpy-company-backend :with company-yasnippet))))))
  :config
  (elpy-enable))
;; Python IDE:2 ends here

;; [[file:config.org::*Scheme][Scheme:1]]
(after! geiser
  (setq geiser-default-implementation 'guile
        geiser-chez-binary "chez-scheme")) ;; default is "scheme"
;; Scheme:1 ends here

;; [[file:config.org::*Magit][Magit:1]]
(after! code-review
  (setq code-review-auth-login-marker 'forge))
;; Magit:1 ends here

;; [[file:config.org::*Granular diff-highlights for /all/ hunks][Granular diff-highlights for /all/ hunks:1]]
(after! magit
  ;; Disable if it causes performance issues
  (setq magit-diff-refine-hunk t))
;; Granular diff-highlights for /all/ hunks:1 ends here

;; [[file:config.org::*Gravatars][Gravatars:1]]
(after! magit
  ;; Show gravatars
  (setq magit-revision-show-gravatars '("^Author:     " . "^Commit:     ")))
;; Gravatars:1 ends here

;; [[file:config.org::*WIP Company for commit messages][WIP Company for commit messages:2]]
(use-package! company-conventional-commits
  :after (magit company)
  :config
  (add-hook
   'git-commit-setup-hook
   (lambda ()
     (add-to-list 'company-backends 'company-conventional-commits))))
;; WIP Company for commit messages:2 ends here

;; [[file:config.org::*Pretty graph][Pretty graph:2]]
(use-package! magit-pretty-graph
  :after magit
  :init
  (setq magit-pg-command
        (concat "git --no-pager log"
                " --topo-order --decorate=full"
                " --pretty=format:\"%H%x00%P%x00%an%x00%ar%x00%s%x00%d\""
                " -n 2000")) ;; Increase the default 100 limit

  (map! :localleader
        :map (magit-mode-map)
        :desc "Magit pretty graph" "p" (cmd! (magit-pg-repo (magit-toplevel)))))
;; Pretty graph:2 ends here

;; [[file:config.org::*Repo][Repo:2]]
(use-package! repo
  :when REPO-P
  :commands repo-status)
;; Repo:2 ends here

;; [[file:config.org::*Blamer][Blamer:2]]
(use-package! blamer
  :commands (blamer-mode)
  ;; :hook ((prog-mode . blamer-mode))
  :custom
  (blamer-idle-time 0.3)
  (blamer-min-offset 60)
  (blamer-prettify-time-p t)
  (blamer-entire-formatter "    %s")
  (blamer-author-formatter " %s ")
  (blamer-datetime-formatter "[%s], ")
  (blamer-commit-formatter "“%s”")
  :custom-face
  (blamer-face ((t :foreground "#7a88cf"
                   :background nil
                   :height 125
                   :italic t))))
;; Blamer:2 ends here

;; [[file:config.org::*Assembly][Assembly:2]]
(use-package! nasm-mode
  :mode "\\.[n]*\\(asm\\|s\\)\\'")

;; Get Haxor VM from https://github.com/krzysztof-magosa/haxor
(use-package! haxor-mode
  :mode "\\.hax\\'")

(use-package! mips-mode
  :mode "\\.mips\\'")

(use-package! riscv-mode
  :mode "\\.riscv\\'")

(use-package! x86-lookup
  :commands (x86-lookup)
  :config
  (when (modulep! :tools pdf)
    (setq x86-lookup-browse-pdf-function 'x86-lookup-browse-pdf-pdf-tools))
  ;; Get manual from https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html
  (setq x86-lookup-pdf (expand-file-name "x86-lookup/325383-sdm-vol-2abcd.pdf" doom-data-dir)))
;; Assembly:2 ends here

;; [[file:config.org::*Devdocs][Devdocs:2]]
(use-package! devdocs
  :commands (devdocs-lookup devdocs-install)
  :config
  (setq devdocs-data-dir (expand-file-name "devdocs" doom-data-dir)))
;; Devdocs:2 ends here

;; [[file:config.org::*PKGBUILD][PKGBUILD:2]]
(use-package! pkgbuild-mode
  :commands (pkgbuild-mode)
  :mode "/PKGBUILD$")
;; PKGBUILD:2 ends here

;; [[file:config.org::*LaTeX][LaTeX:2]]
(use-package! aas
  :commands aas-mode)
;; LaTeX:2 ends here

;; [[file:config.org::*Flycheck + Projectile][Flycheck + Projectile:2]]
(use-package! flycheck-projectile
  :commands flycheck-projectile-list-errors)
;; Flycheck + Projectile:2 ends here

;; [[file:config.org::*Graphviz][Graphviz:2]]
(use-package! graphviz-dot-mode
  :commands graphviz-dot-mode
  :mode ("\\.dot\\'" "\\.gv\\'")
  :init
  (after! org
    (setcdr (assoc "dot" org-src-lang-modes) 'graphviz-dot))

  :config
  (require 'company-graphviz-dot))
;; Graphviz:2 ends here

;; [[file:config.org::*Mermaid][Mermaid:2]]
(use-package! mermaid-mode
  :commands mermaid-mode
  :mode "\\.mmd\\'")

(use-package! ob-mermaid
  :after org
  :init
  (after! org
    (add-to-list 'org-babel-load-languages '(mermaid . t))))
;; Mermaid:2 ends here

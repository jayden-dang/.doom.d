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

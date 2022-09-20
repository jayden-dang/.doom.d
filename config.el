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

;;; packages.el -*- coding: utf-8-unix; lexical-binding: t; -*-
;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here and run 'doom sync'
;; on the command line, then restart Emacs for the changes to take effect -- or
;; use 'M-x doom/reload'.


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;(package! some-package)

;; To install a package directly from a remote git repo, you must specify a
;; `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/raxod502/straight.el#the-recipe-format
;(package! another-package
;  :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;(package! this-package
;  :recipe (:host github :repo "username/repo"
;           :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
;(package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;(package! builtin-package :recipe (:nonrecursive t))
;(package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see raxod502/straight.el#279)
;(package! builtin-package :recipe (:branch "develop"))

;; Use `:pin' to specify a particular commit to install.
;(package! builtin-package :pin "1a2b3c4d5e")


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
;(unpin! pinned-package)
;; ...or multiple packages
;(unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
;(unpin! t)

;; (package! gitconfig-mode
;; 	  :recipe (:host github :repo "magit/git-modes"
;; 			 :files ("gitconfig-mode.el")))
;; (package! gitignore-mode
;; 	  :recipe (:host github :repo "magit/git-modes"
;; 			 :files ("gitignore-mode.el")))

(package! org-ql)

(package! vundo
  :recipe (:host github
           :repo "casouri/vundo")
  :pin "16a09774ddfbd120d625cdd35fcf480e76e278bb")

(package! svg-tag-mode :pin "efd22edf650fb25e665269ba9fed7ccad0771a2f")

(package! focus :pin "9dd85fc474bbc1ebf22c287752c960394fcd465a")

(package! all-the-icons)

(package! vlf)

(package! evil-escape :disable t)

(package! aggressive-indent :pin "70b3f0add29faff41e480e82930a231d88ee9ca7")

(package! info-colors :pin "47ee73cc19b1049eef32c9f3e264ea7ef2aaf8a5")

(package! ag :pin "ed7e32064f92f1315cecbfc43f120bbc7508672c")

(unpin! lsp-mode)

(package! tree-sitter)
(package! tree-sitter-langs)

(package! maple-iedit
  :recipe (:host github
           :repo "honmaple/emacs-maple-iedit"))

;; (package! engine-mode)

;; (package! bm)

(package! elpy :pin "de31d30003c515c25ff7bfd3a361c70c298f78bb")

(package! magit-pretty-graph
  :recipe (:host github
           :repo "georgek/magit-pretty-graph"))

(package! repo :pin "e504aa831bfa38ddadce293face28b3c9d9ff9b7")

(package! blamer
  :recipe (:host github
           :repo "artawower/blamer.el")
  :pin "99b43779341af0d924bfe2a9103993a6b9e3d3b2")

(package! devdocs
  :recipe (:host github
           :repo "astoff/devdocs.el"
           :files ("*.el"))
  :pin "61ce83b79dc64e2f99d7f016a09b97e14b331459")

(package! pkgbuild-mode :pin "9525be8ecbd3a0d0bc7cc27e6d0f403e111aa067")

(package! flycheck-projectile
  :recipe (:host github
           :repo "nbfalcon/flycheck-projectile")
  :pin "ce6e9e8793a55dace13d5fa13badab2dca3b5ddb")

(package! graphviz-dot-mode :pin "6e96a89762760935a7dff6b18393396f6498f976")

(package! mermaid-mode :pin "a98a9e733b1da1e6a19e68c1db4367bf46283479")

(package! aas
  :recipe (:host github
           :repo "ymarco/auto-activating-snippets")
  :pin "566944e3b336c29d3ac11cd739a954c9d112f3fb")

(package! org-roam-ui :recipe (:host github :repo "org-roam/org-roam-ui" :files ("*.el" "out")) :pin "5ac74960231db0bf7783c2ba7a19a60f582e91ab")
(package! websocket :pin "40c208eaab99999d7c1e4bea883648da24c03be3") ; dependency of `org-roam-ui'

(package! editorconfig)
(package! markdown-preview-mode)
(package! move-text)

(package! ivy-posframe)

(package! vundo
  :recipe (:host github
           :repo "casouri/vundo")
  :pin "16a09774ddfbd120d625cdd35fcf480e76e278bb")

(package! svg-tag-mode :pin "efd22edf650fb25e665269ba9fed7ccad0771a2f")

(package! focus :pin "9dd85fc474bbc1ebf22c287752c960394fcd465a")

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

(package! company-conventional-commits
  :recipe `(:local-repo ,(expand-file-name "lisp/company-conventional-commits" doom-user-dir)))

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

(package! editorconfig)
(package! markdown-preview-mode)
(package! move-text)

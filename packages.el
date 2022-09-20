;; [[file:config.org::*Additional packages (=packages.el=)][Additional packages (=packages.el=):1]]
;; -*- coding: utf-8-unix; no-byte-compile: t; -*-
;; Additional packages (=packages.el=):1 ends here

;; [[file:config.org::*Visual undo (=vundo=)][Visual undo (=vundo=):1]]
(package! vundo
  :recipe (:host github
           :repo "casouri/vundo")
  :pin "16a09774ddfbd120d625cdd35fcf480e76e278bb")
;; Visual undo (=vundo=):1 ends here

;; [[file:config.org::*Modus themes][Modus themes:1]]
(package! modus-themes)
;; Modus themes:1 ends here

;; [[file:config.org::*SVG tag and =svg-lib=][SVG tag and =svg-lib=:1]]
(package! svg-tag-mode :pin "efd22edf650fb25e665269ba9fed7ccad0771a2f")
;; SVG tag and =svg-lib=:1 ends here

;; [[file:config.org::*Focus][Focus:1]]
(package! focus :pin "9dd85fc474bbc1ebf22c287752c960394fcd465a")
;; Focus:1 ends here

;; [[file:config.org::*Scrolling][Scrolling:1]]
(package! good-scroll
  :disable EMACS29+
  :pin "a7ffd5c0e5935cebd545a0570f64949077f71ee3")
;; Scrolling:1 ends here

;; [[file:config.org::*Very large files][Very large files:1]]
(package! vlf :pin "cc02f2533782d6b9b628cec7e2dcf25b2d05a27c")
;; Very large files:1 ends here

;; [[file:config.org::*Evil][Evil:2]]
(package! evil-escape :disable t)
;; Evil:2 ends here

;; [[file:config.org::*Aggressive indent][Aggressive indent:1]]
(package! aggressive-indent :pin "70b3f0add29faff41e480e82930a231d88ee9ca7")
;; Aggressive indent:1 ends here

;; [[file:config.org::*Erefactor][Erefactor:1]]
(package! erefactor
  :recipe (:host github
           :repo "mhayashi1120/Emacs-erefactor")
  :pin "bfe27a1b8c7cac0fe054e76113e941efa3775fe8")
;; Erefactor:1 ends here

;; [[file:config.org::*Lorem ipsum][Lorem ipsum:1]]
(package! emacs-lorem-ipsum
  :recipe (:host github
           :repo "jschaf/emacs-lorem-ipsum")
  :pin "da75c155da327c7a7aedb80f5cfe409984787049")
;; Lorem ipsum:1 ends here

;; [[file:config.org::*Coverage test][Coverage test:1]]
(package! cov :pin "cd3e1995c596cc227124db9537792d8329ffb696")
;; Coverage test:1 ends here

;; [[file:config.org::*Unpin package][Unpin package:1]]
(unpin! lsp-mode)
;; Unpin package:1 ends here

;; [[file:config.org::*SonarLint][SonarLint:1]]
(package! lsp-sonarlint
  :disable t :pin "3313f38ed7d23947992e19f1e464c6d544124144")
;; SonarLint:1 ends here

;; [[file:config.org::*Project CMake][Project CMake:1]]
(package! project-cmake
  :disable t ; (not (modulep! :tools lsp +eglot)) ; Enable only if (lsp +eglot) is used
  :pin "3313f38ed7d23947992e19f1e464c6d544124144"
  :recipe (:host github
           :repo "juanjosegarciaripoll/project-cmake"))
;; Project CMake:1 ends here

;; [[file:config.org::*Clang-format][Clang-format:1]]
(package! clang-format :pin "e48ff8ae18dc7ab6118c1f6752deb48cb1fc83ac")
;; Clang-format:1 ends here

;; [[file:config.org::*Auto-include C++ headers][Auto-include C++ headers:1]]
(package! cpp-auto-include
  :recipe (:host github
           :repo "emacsorphanage/cpp-auto-include")
  :pin "0ce829f27d466c083e78b9fe210dcfa61fb417f4")
;; Auto-include C++ headers:1 ends here

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

;; [[file:config.org::*Grammarly][Grammarly:1]]
(package! grammarly
  :recipe (:host github
           :repo "emacs-grammarly/grammarly")
  :pin "e47b370faace9ca081db0b87ae3bcfd73212c56d")
;; Grammarly:1 ends here

;; [[file:config.org::*Eglot][Eglot:1]]
(package! eglot-grammarly
  :disable (not (modulep! :tools lsp +eglot))
  :recipe (:host github
           :repo "emacs-grammarly/eglot-grammarly")
  :pin "3313f38ed7d23947992e19f1e464c6d544124144")
;; Eglot:1 ends here

;; [[file:config.org::*LSP Mode][LSP Mode:1]]
(package! lsp-grammarly
  :disable (or (not (modulep! :tools lsp)) (modulep! :tools lsp +eglot))
  :recipe (:host github
           :repo "emacs-grammarly/lsp-grammarly")
  :pin "eab5292037478c32e7d658fb5cba8b8fb6d72a7c")
;; LSP Mode:1 ends here

;; [[file:config.org::*Grammalecte][Grammalecte:1]]
(package! flycheck-grammalecte
  :recipe (:host github
           :repo "milouse/flycheck-grammalecte")
  :pin "314de13247710410f11d060a214ac4f400c02a71")
;; Grammalecte:1 ends here

;; [[file:config.org::*Go Translate (Google, Bing and DeepL)][Go Translate (Google, Bing and DeepL):1]]
(package! go-translate
  :recipe (:host github
           :repo "lorniu/go-translate")
  :pin "8bbcbce42a7139f079df3e9b9bda0def2cbb690f")
;; Go Translate (Google, Bing and DeepL):1 ends here

;; [[file:config.org::*Offline dictionaries][Offline dictionaries:1]]
(package! lexic
  :recipe (:host github
           :repo "tecosaur/lexic")
  :pin "f9b3de4d9c2dd1ce5022383e1a504b87bf7d1b09")
;; Offline dictionaries:1 ends here

;; [[file:config.org::*Info colors][Info colors:1]]
(package! info-colors :pin "47ee73cc19b1049eef32c9f3e264ea7ef2aaf8a5")
;; Info colors:1 ends here

;; [[file:config.org::*The Silver Searcher][The Silver Searcher:1]]
(package! ag :pin "ed7e32064f92f1315cecbfc43f120bbc7508672c")
;; The Silver Searcher:1 ends here

;; [[file:config.org::*Page break lines][Page break lines:1]]
(package! page-break-lines :pin "79eca86e0634ac68af862e15c8a236c37f446dcd")
;; Page break lines:1 ends here

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

;; [[file:config.org::*DAP][DAP:1]]
(unpin! dap-mode)
;; DAP:1 ends here

;; [[file:config.org::*Maxima][Maxima:1]]
(package! maxima
  :recipe (:host github
           :repo "emacsmirror/maxima"
           :files (:defaults
                   "keywords"
                   "company-maxima.el"
                   "poly-maxima.el"))
  :pin "1334f44725bd80a265de858d652f3fde4ae401fa")
;; Maxima:1 ends here

;; [[file:config.org::*IMaxima][IMaxima:1]]
;; Use the `imaxima' package bundled with the official Maxima distribution.
(package! imaxima
  :recipe (:host nil ;; Unsupported host, we will specify the complete repo link
           :repo "https://git.code.sf.net/p/maxima/code"
           :files ("interfaces/emacs/imaxima/*"))
  :pin "519ea34095e749634d3a188733a3ad284b593e12")
;; IMaxima:1 ends here

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

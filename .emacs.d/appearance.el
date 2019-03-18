
(setq solarized-distinct-fringe-background t)

;; Don't change the font for some headings and titles
(setq solarized-use-variable-pitch nil)

;; make the modeline high contrast
(setq solarized-high-contrast-mode-line t)

;; Use less bolding
(setq solarized-use-less-bold t)

;; Use more italics
(setq solarized-use-more-italic t)

;; Use less colors for indicators such as git:gutter, flycheck and similar
(setq solarized-emphasize-indicators nil)

;; Don't change size of org-mode headlines (but keep other size-changes)
(setq solarized-scale-org-headlines nil)

;; Avoid all font-size changes
(setq solarized-height-minus-1 1.0)
(setq solarized-height-plus-1 1.0)
(setq solarized-height-plus-2 1.0)
(setq solarized-height-plus-3 1.0)
(setq solarized-height-plus-4 1.0)

(load-theme 'solarized-light t)

;; Fonts
(if (string= (system-name) "thinkpad")
  (set-face-attribute 'default nil :font "Droid Sans Mono for Powerline-12")
  (set-face-attribute 'default nil :font "Droid Sans Mono for Powerline-11"))

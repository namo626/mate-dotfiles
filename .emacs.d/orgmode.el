
(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)

;;(setq org-log-done t)

(setq org-hide-emphasis-markers t)
(setq org-agenda-files (list "~/Dropbox/work.org"
			     "~/Dropbox/personal.org"))



;;increase LaTeX size
(setq org-format-latex-options (plist-put org-format-latex-options :scale 1.5))

;;diary location
(setq diary-file "~/Dropbox/diary")

;;fancy display
(setq view-diary-entries-initially t
       mark-diary-entries-in-calendar t
       number-of-diary-entries 7)
(add-hook 'diary-display-hook 'fancy-diary-display)
(add-hook 'today-visible-calendar-hook 'calendar-mark-today)


(setq org-agenda-include-diary t)
;(setq calendar-mark-diary-entries-flag t)

(defun kill-to-end-of-buffer() "Deletes all lines after the current line"
  (interactive)
  (progn
    (forward-line 1)
    (delete-region (point) (point-max))))

;; google cal
(setq mark-diary-entries-in-calendar t)
(add-hook 'diary-mark-entries-hook 'diary-mark-included-diary-files)
(add-hook 'diary-list-entries-hook 'diary-sort-entries t)
(add-hook 'diary-list-entries-hook 'diary-include-other-diary-files)
(defun getcal (url)
  "Download ics file and add to diary"
  (let ((tmpfile (url-file-local-copy url)))
    (icalendar-import-file tmpfile "~/Dropbox/diary" t)
    (kill-buffer (car (last (split-string tmpfile "/"))))
    )
  )
(load "~/Dropbox/gcal.el")
(defun getcals ()
  (interactive)
  (find-file "~/Dropbox/diary")
  (flush-lines "^.")
  (dolist (url google-calendars) (getcal url))
  (beginning-of-buffer)
  (replace-string "&" "")
  (save-buffer)
  (kill-buffer "diary"))

;;longer agenda
(setq org-agenda-span 10
      org-agenda-start-day "-3d")


(setq org-default-notes-file (concat org-directory "/notes.org"))
(define-key global-map "\C-cc" 'org-capture)

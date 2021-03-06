;;; bibtex-hotkeys.el --- Hotkeys for bibtex files.

;;; Commentary:
;; This is an experimental module to add hotkeys to bibtex files. The idea is
;; when the cursor is on the @ at the beginning of an entry, then you can press
;; single keys to perform actions like navigation, copy, kill, move entries,
;; etc.
;;
;; There is one macro `bibtex-hotkey' for defining hotkey actions.

;;; Code:

(defvar bibtex-hotkeys
  '()
  "Stores keys and docstrings.")


(defmacro bibtex-hotkey (s &rest body)
  "Define the key S to execute BODY when at the beginning of a bibtex entry."
  (let ((docstring (when (stringp (first body)) (first body)))
	(known (assoc s bibtex-hotkeys)))
    (if known
	(setf (cdr known) docstring)
      (add-to-list 'bibtex-hotkeys (cons s docstring)))
    (when docstring (setq body (cdr body)))
    `(define-key bibtex-mode-map ,s
       (lambda ()
	 ,docstring
	 (interactive)
	 (if (or (looking-at "^@") (and (bolp) (not (bibtex-in-entry-p))))
	     (progn ,@body)
	   (insert ,s))))))


(defun bibtex-in-entry-p ()
  "Return if the point is in a bibtex entry."
  (let ((p (point))
	b e)
    (save-excursion
      (bibtex-beginning-of-entry)
      (setq b (point))
      (bibtex-end-of-entry)
      (setq e (point))
      (and (> e p)
	   (< b p)))))

(bibtex-hotkey "b" "Open in browser" (org-ref-open-in-browser))

(bibtex-hotkey "c" "Copy entry"
	       (bibtex-kill-entry t)
	       (message (substitute-command-keys "\\[bibtex-yank] to paste.")))

(bibtex-hotkey "e" "Email entry" (org-ref-email-bibtex-entry))

(bibtex-hotkey "f" "Copy formatted"
	       (kill-new
		(org-ref-format-entry
		 (cdr (assoc "=key=" (bibtex-parse-entry t))))))

(bibtex-hotkey "k" "Kill the entry" (bibtex-kill-entry))

(bibtex-hotkey "I" "Inspect" (message "%s" (bibtex-parse-entry t)))

(bibtex-hotkey "n" "Jump to next entry" (org-ref-bibtex-next-entry))

(bibtex-hotkey "p" "Jump to previous entry" (org-ref-bibtex-previous-entry))

(bibtex-hotkey "?" "Show hotkeys"
	       (message "%s"
			(mapconcat
			 (lambda (c)
			   (format "%s %s" (car c) (cdr c)))
			 (sort (copy-list bibtex-hotkeys) (lambda (c1 c2)
							    (string< (car c1) (car c2))))
			 "\n")))

(bibtex-hotkey "F" "Jump to field with avy"
	       (let* ((beg (point))
		      (e (save-excursion (bibtex-parse-entry)))
		      (end (save-excursion (bibtex-end-of-entry) (point)))
		      (fields (mapcar 'car e))
		      (regex (concat (regexp-opt fields) " +=")))
		 (avy-with bibtex-goto-field
		   (avy--generic-jump regex nil avy-style beg end))))


(bibtex-hotkey "s"
	       "Move entry up"
	       (bibtex-kill-entry)
	       (org-ref-bibtex-next-entry)
	       (bibtex-end-of-entry)
	       (insert "\n")
	       (bibtex-yank)
	       (bibtex-beginning-of-entry))


(bibtex-hotkey "w"
	       "Move entry down"
	       (bibtex-kill-entry)
	       (backward-char)
	       (bibtex-beginning-of-entry)
	       (save-excursion
		 (bibtex-yank)))

(bibtex-hotkey "y" "Paste last entry" (bibtex-yank))



(provide 'bibtex-hotkeys)

;;; bibtex-hotkeys.el ends here

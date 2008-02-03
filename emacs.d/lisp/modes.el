;;; Lisp mode
(require 'paredit)

; Set up slime
(setq inferior-lisp-program "/usr/bin/sbcl")
(require 'slime)
(slime-setup)
(setq slime-net-coding-system 'utf-8-unix)
;; Fix indentation
(defun gimme-local-map ()
  (or (current-local-map)
      ;; The following creates a map, returns
      ;; nil and falls through.
      (use-local-map (make-sparse-keymap))
      (current-local-map)))

(defun my-lisp-mode-hook ()
  (set (make-local-variable 'lisp-indent-function)
       'common-lisp-indent-function)
  (paredit-mode)
  (define-key (gimme-local-map)
    "\t" (lexical-let ((tab-mode 0)
		       (timer nil)
		       (pfx nil)
		       (reset-fn (lambda ()
				   (setq tab-mode 0))))
	   (lambda ()
	     (interactive)
	     (case tab-mode
	       (0 (funcall indent-line-function)
		  (setq pfx current-prefix-arg))
	       (1 (save-excursion
		    (beginning-of-defun)
		    (setq current-prefix-arg pfx)
		    (call-interactively 'indent-pp-sexp)))
	       (t nil))
	     (setq tab-mode (1+ tab-mode))
		
	     (when timer
	       (cancel-timer timer))
	     (setq timer
		   (run-at-time .5 nil
				(lambda () (setq tab-mode 0))))))))
(setq ispell-program-name "aspell")


(defface page-pp '((default :weight bold :slant italic :foreground "green" :box (:line-width 2 :style pressed-button)))
  "Pretty-printed page break (^L)")

(defun page-pp-display-vec ()
  (map 'vector (lambda (x) (make-glyph-code x 'page-pp))
       "          Page Break          "))

(progn
  (unless standard-display-table
    (setf standard-display-table (make-display-table)))
  (aset standard-display-table ?\C-L
	(page-pp-display-vec)))

(add-hook 'lisp-mode-hook
	  'my-lisp-mode-hook)
(add-hook 'emacs-lisp-mode-hook
	  'my-lisp-mode-hook)

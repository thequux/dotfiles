;;; Lisp mode
(require 'paredit)

; Set up slime
(setq inferior-lisp-program "/usr/local/bin/lisp")
(require 'slime)
(slime-setup)

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
(add-hook 'lisp-mode-hook
	  'my-lisp-mode-hook)
(add-hook 'emacs-lisp-mode-hook
	  'my-lisp-mode-hook)

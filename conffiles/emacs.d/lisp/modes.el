;;; custom modes
(require 'ucode)

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
       "          Page Break          \n"))

(progn
  (unless standard-display-table
    (setf standard-display-table (make-display-table)))
  (aset standard-display-table ?\C-L
	(page-pp-display-vec)))


(defun my-haskell-comment-mode-hook ()
  (interactive)
  (define-key (gimme-local-map)
      [?\C--] (lambda ()
		(interactive)
		(insert "--"))))
(add-hook 'haskell-mode-hook
	  'my-haskell-comment-mode-hook)
(add-hook 'lisp-mode-hook
	  'my-lisp-mode-hook)
(add-hook 'emacs-lisp-mode-hook
	  'my-lisp-mode-hook)

; load haskell
(load-library "haskell-mode")
(load-library "haskell-indent")
(load-library "haskell-doc")
(load-library "haskell-ghci")
(load-library "inf-haskell")

;;; nxml config
(load-library "nxml-mode")

(add-to-list 'auto-mode-alist
             '("\\.html?\\'" . nxml-mode))
(defcustom nxml-doctype-alist
  '(("html4.01-strict" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">")
    ("html4.01-frameset" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\" \"http://www.w3.org/TR/html4/frameset.dtd\">")
    ("html4.01-transitional" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/transitional.dtd\">")
    ("xhtml1.0-strict" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">")
    ("xhtml1.0-transitional" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">")
    ("xhtml1.0-frameset" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Frameset//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd\">")
    ("xhtml1.0-basic" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML Basic 1.0//EN\" \"http://www.w3.org/TR/xhtml-basic/xhtml-basic10.dtd\">")
    ("xhtml1.1" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">")
    ("xhtml1.1-basic" . "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML Basic 1.1//EN\" \"http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd\">")

    )
  "An alist of doctypes; used for nxml-insert-doctype"
  :type '(alist 
          :key-type string 
          :value-type (list (string :tag "Doctype")
                       (string :tag "xmlns")))
  :group 'nxml
  )

(defun nxml-insert-doctype ()
  "Insert a doctype into the current document"
  (interactive)
  )


;;; Basic setup...
(require 'cl)

(setq custom-file "~/.emacs.d/lisp/my-custom.el")
;(load custom-file)


(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'load-path "~/.emacs.d")
(load "modes")
(load "planner-rc")
(load "my-custom")
;(load "edesk")
(require 'erc)

(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

(defun vim-warning ()
  (interactive)
  (message "This ain't vim!")
  (beep))
(defun noop ()
  (interactive))
;; This sucks with literate haskell
;(global-set-key [?\r ] 'newline-and-indent)
(global-set-key [?\M-: ] 'vim-warning)
;(global-set-key [?\C-w ] 'backward-kill-word)
(global-set-key [?\e ?`] 'noop)
(global-set-key [?\e ?\e ?`] 'noop)

; Lisp stuff...
;	  (lambda ()
;    (set (make-local-variable 'lisp-indent-function)
; 'common-lisp-indent-function)))

(autoload 'predictive-mode "predictive" "predictive" t)
(set-default 'predictive-auto-add-to-dict t)
(setq predictive-main-dict 'tq-dict
      predictive-auto-learn t
      predictive-add-to-dict-ask nil
      predictive-use-auto-learn-cache nil
      predictive-which-dict t)


(setq visible-bell 'top-bottom)
;; Planner stuff...

;(global-set-key)

(server-start)


(put 'overwrite-mode 'disabled t)

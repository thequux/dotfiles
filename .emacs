;;; Basic setup...
(require 'cl)


(add-to-list 'load-path "/home/thequux/.emacs.d/lisp")
(add-to-list 'load-path "/home/thequux/.emacs.d")
(load "modes")
(load "planner-rc")
(load "my-custom")
(load "edesk")
(require 'erc)

(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

(defun vim-warning ()
  (interactive)
  (message "This ain't vim!")
  (beep))
(defun noop ()
  (interactive))
(global-set-key [?\r ] 'newline-and-indent)
(global-set-key [?\M-: ] 'vim-warning)
(global-set-key [?\C-w ] 'backward-kill-word)
(global-set-key [?\e ?`] 'noop)
(global-set-key [?\e ?\e ?`] 'noop)

; Lisp stuff...
;	  (lambda ()
;    (set (make-local-variable 'lisp-indent-function)
; 'common-lisp-indent-function)))


 (setq visible-bell 'top-bottom)
;; Planner stuff...

;(global-set-key)

(server-start)

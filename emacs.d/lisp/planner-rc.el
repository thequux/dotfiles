(setq muse-project-alist
      '(("WikiPlanner"
	 ("~/plans"
	  :default "index"
	  :major-mode planner-mode
	  :visit-link planner-visit-link))))
(require 'planner)

;;; setup bindings
;; Note that f1 is bound to the help keymap by default, and if I don't change it, all
;; of these bindings will also be avaliable at C-h <whatever>. I happen to like C-h as it is.
(global-set-key [f1] (make-sparse-keymap))

(global-set-key [f1 f1 ] 'plan)
(global-set-key [f1 ?n] 'planner-create-task-from-buffer)
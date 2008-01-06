;;; A simple emacs-managed desktop...
(defun edesk ()
  (interactive)
  (global-unset-key [?\C-z])
  ;;Note that I assume that all libraries are pre-loaded in some way.
  (plan))
(if (equal "edesk" (frame-parameter nil 'name))
    (edesk))


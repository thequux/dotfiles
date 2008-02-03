;;; This file has site-specific configuration...
;;;
;;; The way it works is that each site (host/OS.. technically, each
;;; installation) gets a name, and the current name is stored in
;;; *tq-site-name*  Then, each feature that requires external packages
;;; is selected based on the hostname. Kapich?

(defvar *tq-site-name*
  (cond ((string= (system-name) "peewee.thequux.com")
	 (case system-type
	   (gnu/linux :peewee-linux)
	   (berkeley-unix :peewee-bsd)
	   (t :unknown)))
	((string= (system-name) "krogoth.dorm-thequux.com") :krogoth)
	(t :unknown))
  "The name of this installation of Emacs")

(if (eql *tq-site-name* :unknown)
    (message "System name %W not recognized; please add it to tq-site.el" (system-name)))

(defmacro tq-at-site (sites &rest commands)
  `(when (member *tq-site-name* ',sites)
     ,@commands))

(tq-at-site (:peewee-linux)
	    (add-to-list 'load-path "/usr/local/share/emacs/site-lisp"))
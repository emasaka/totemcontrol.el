;; totemcontrol.el: Control Totem from Emacs (especially for audiotyping)
;; to use this, enable D-Bus service plugin of Totem (Edit -> Plugins).

(require 'dbus)

(defconst TOTEM-BUS-NAME "org.mpris.Totem")
(defconst TOTEM-INTERFACE "org.freedesktop.MediaPlayer")
(defconst TOTEM-CONTROL-PATH "/Player")

(defun totem-check-running ()
  (or (member TOTEM-BUS-NAME (dbus-list-known-names :session))
      (progn (message "Error: Run Totem and enable dbus-service plugin!")
	     nil )))

(defmacro totem-call-method (method &rest args)
  `(dbus-call-method :session ,TOTEM-BUS-NAME ,TOTEM-CONTROL-PATH
		     ,TOTEM-INTERFACE ,method ,@args ))

(defun totem-pause ()
  "Toggle Totem pause and resume"
  (interactive)
  (when (totem-check-running)
    (totem-call-method "Pause") ))

(defun totem-back (sec)
  (when (totem-check-running)
    (totem-call-method
     "PositionSet"
     (max (- (totem-call-method "PositionGet") (* sec 1000)) 0) )))

(defun totem-back-2sec ()
  "Back Totem 2 seconds"
  (interactive)
  (totem-back 2) )

(defun totem-back-5sec ()
  "Back Totem 5 seconds"
  (interactive)
  (totem-back 5) )

(global-set-key (kbd "C-.") #'totem-pause)
(global-set-key (kbd "C-(") #'totem-back-2sec)
(global-set-key (kbd "C-<") #'totem-back-5sec)

;; totemcontrol.el: Control Totem from Emacs (especially for audiotyping)
;; to use this, enable D-Bus service plugin of Totem (Edit -> Plugins).

(require 'dbus)

(defconst TOTEM-BUS-NAME "org.mpris.MediaPlayer2.totem")
(defconst TOTEM-INTERFACE "org.mpris.MediaPlayer2.Player")
(defconst TOTEM-CONTROL-PATH "/org/mpris/MediaPlayer2")

;;; functions and macros
(defun totem-check-running ()
  (or (member TOTEM-BUS-NAME (dbus-list-known-names :session))
      (progn (message "Error: Totem is not runnning or dbus-service plugin is not enabled")
	     nil )))

(defmacro totem-call-method (method &rest args)
  `(dbus-call-method :session ,TOTEM-BUS-NAME ,TOTEM-CONTROL-PATH
		     ,TOTEM-INTERFACE ,method ,@args ))
    (totem-call-method "PlayPause") ))

(defun totem-seek (offset)
  (when (totem-check-running)
    (totem-call-method "Seek" offset) ))

;;; commands
(defun totem-playpause ()
  "Toggle Totem pause and resume"
  (interactive)
  (when (totem-check-running)

(defun totem-back-2sec ()
  "Back Totem 2 seconds"
  (interactive)
  (totem-seek -2000000) )

(defun totem-forward-2sec ()
  "Forward Totem 2 seconds"
  (interactive)
  (totem-seek 2000000) )

(defun totem-back-5sec ()
  "Back Totem 5 seconds"
  (interactive)
  (totem-seek -5000000) )

(defun totem-forward-5sec ()
  "Forward Totem 5 seconds"
  (interactive)
  (totem-seek 5000000) )

;;; totemcontrol-mode
(defvar totemcontrol-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-.") 'totem-playpause)
    (define-key map (kbd "C-(") 'totem-back-2sec)
    (define-key map (kbd "C-)") 'totem-forward-2sec)
    (define-key map (kbd "C-<") 'totem-back-5sec)
    (define-key map (kbd "C->") 'totem-forward-5sec)
    map ))

(define-minor-mode totemcontrol-mode
  "Totemcontrol mode"			; document
  nil					; initianl value
  " Totem"				; mode line string
  totemcontrol-mode-map )		; keymap

(provide 'totemcontrol)

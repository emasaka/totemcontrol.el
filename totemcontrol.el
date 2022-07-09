;; totemcontrol.el: Control Totem from Emacs (especially for audiotyping)
;; to use this, enable D-Bus service plugin of Totem (Edit -> Plugins).

(require 'dbus)

(defconst TOTEMCONTROL-INTERFACE "org.mpris.MediaPlayer2.Player")
(defconst TOTECONTROLM-CONTROL-PATH "/org/mpris/MediaPlayer2")

(defvar totemcontrol-bus-name)
(defconst TOTEM-BUS-NAME "org.mpris.MediaPlayer2.totem")
(defconst VLC-BUS-NAME "org.mpris.MediaPlayer2.vlc")
(defconst FX-MPRIS-BUS-NAME "org.mpris.MediaPlayer2.firefox")

;;; functions and macros
(defun totem-check-running ()
  (or (member totemcontrol-bus-name (dbus-list-known-names :session))
      (progn (message "Error: Totem is not runnning or dbus-service plugin is not enabled")
	     nil )))

(defmacro totem-call-method (method &rest args)
  `(dbus-call-method :session totemcontrol-bus-name ,TOTECONTROLM-CONTROL-PATH
		     ,TOTEMCONTROL-INTERFACE ,method ,@args ))

(defun totem-seek (offset)
  (when (totem-check-running)
    (totem-call-method "Seek" :int64 offset) ))

;;; commands
(defun totem-playpause ()
  "Toggle Totem pause and resume"
  (interactive)
  (when (totem-check-running)
    (totem-call-method "PlayPause") ))

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
  totemcontrol-mode-map			; keymap
  (when totemcontrol-mode		; body
    (setq-local totemcontrol-bus-name TOTEM-BUS-NAME) ))

(define-minor-mode vlccontrol-mode
  "VLCcontrol mode"			; document
  nil					; initianl value
  " VLC"				; mode line string
  totemcontrol-mode-map			; keymap
  (when vlccontrol-mode			; body
    (setq-local totemcontrol-bus-name VLC-BUS-NAME) ))

;; fx-mpris-mode (just workaround)
(defun totem-find-dbus-name (pattern)
  (car					; workaround
   (seq-filter (lambda (x) (string-match-p pattern x))
	       (dbus-list-names :session) )))

(defmacro fx-mpris-call-method (method &rest args)
  `(if-let ((busname (totem-find-dbus-name totemcontrol-bus-name-re)))
       (dbus-call-method :session busname ,TOTECONTROLM-CONTROL-PATH
			 ,TOTEMCONTROL-INTERFACE ,method ,@args )
     (message "Error: player not found") ))

(defun fx-mpris-playpause ()
  (interactive)
  (fx-mpris-call-method "PlayPause") )

(defvar fx-mpris-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-.") 'fx-mpris-playpause)
    map ))

(define-minor-mode fx-mpris-mode
  "Firefox MPRIS mode"			; document
  nil					; initianl value
  " fx-mpris"				; mode line string
  fx-mpris-mode-map			; keymap
  (when fx-mpris-mode			; body
    (setq-local totemcontrol-bus-name-re (regexp-quote FX-MPRIS-BUS-NAME)) ))

(provide 'totemcontrol)

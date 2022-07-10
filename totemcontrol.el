;; totemcontrol.el: Control Totem from Emacs (especially for audiotyping)
;; to use this, enable D-Bus service plugin of Totem (Edit -> Plugins).

(require 'dbus)

(defconst TOTEMCONTROL-INTERFACE "org.mpris.MediaPlayer2.Player")
(defconst TOTECONTROL-CONTROL-PATH "/org/mpris/MediaPlayer2")

(defvar totemcontrol-bus-name-re)
(defconst TOTEM-BUS-NAME "org.mpris.MediaPlayer2.totem")
(defconst VLC-BUS-NAME "org.mpris.MediaPlayer2.vlc")
(defconst FX-MPRIS-BUS-NAME "org.mpris.MediaPlayer2.firefox")

;;; functions and macros
(defun totem-find-dbus-name (pattern)
  (car					; workaround: first bus name only
   (seq-filter (lambda (x) (string-match-p pattern x))
	       (dbus-list-names :session) )))

(put 'with-mpris-bus-name 'lisp-indent-function 1)
(defmacro with-mpris-bus-name (varlist &rest body)
  `(if-let ((,(car varlist) (totem-find-dbus-name totemcontrol-bus-name-re)))
       (progn ,@body)
     (message "Error: player not found") ))

(defmacro totem-call-method (method &rest args)
  `(with-mpris-bus-name (busname)
     (dbus-call-method :session busname ,TOTECONTROL-CONTROL-PATH
		       ,TOTEMCONTROL-INTERFACE ,method ,@args )))

(defun totem-seek (offset)
  (with-mpris-bus-name (busname)
    (if (dbus-get-property :session busname TOTECONTROL-CONTROL-PATH
			   TOTEMCONTROL-INTERFACE "CanSeek" )
	(dbus-call-method :session busname TOTECONTROL-CONTROL-PATH
			  TOTEMCONTROL-INTERFACE "Seek" :int64 offset )
      (message "Error: can't seek") )))

;;; commands
(defun totem-playpause ()
  "Toggle pause and resume"
  (interactive)
  (totem-call-method "PlayPause") )

(defun totem-back-2sec ()
  "Back 2 seconds"
  (interactive)
  (totem-seek -2000000) )

(defun totem-forward-2sec ()
  "Forward 2 seconds"
  (interactive)
  (totem-seek 2000000) )

(defun totem-back-5sec ()
  "Back 5 seconds"
  (interactive)
  (totem-seek -5000000) )

(defun totem-forward-5sec ()
  "Forward 5 seconds"
  (interactive)
  (totem-seek 5000000) )

;;; minor modes
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
    (setq-local totemcontrol-bus-name-re (regexp-quote TOTEM-BUS-NAME)) ))

(define-minor-mode vlccontrol-mode
  "VLCcontrol mode"			; document
  nil					; initianl value
  " VLC"				; mode line string
  totemcontrol-mode-map			; keymap
  (when vlccontrol-mode			; body
    (setq-local totemcontrol-bus-name-re (regexp-quote VLC-BUS-NAME)) ))

(define-minor-mode fx-mpris-mode
  "Firefox MPRIS mode"			; document
  nil					; initianl value
  " Fx-mpris"				; mode line string
  totemcontrol-mode-map			; keymap
  (when fx-mpris-mode			; body
    (setq-local totemcontrol-bus-name-re (regexp-quote FX-MPRIS-BUS-NAME)) ))

(provide 'totemcontrol)

(defvar ucode-mode-syntax-table
  (let ((st (make-syntax-table)))
    (modify-syntax-entry ?\; "<" st)
    (modify-syntax-entry ?\n ">" st)
    st))

(defvar ucode-mode-keywords
  (list
   (regexp-opt'(
                ".DCODE"
                ".UCODE"
                ".TITLE"
                ".TOC"
                ".SET"
                ".CHANGE"
                ".DEFAULT"
                ".IF"
                ".IFNOT"
                ".ENDIF"
                ".NOBIN"
                ".BIN"
                ".WIDTH"
                ".RAMFILE"
                ))
   ))

(defvar ucode-display-table
  (let ((ct (make-display-table)))
    (map-char-table (lambda (k v)
                      (aset ct k v))
                    standard-display-table)
    ;     (set-char-table-parent ct standard-display-table)
    (aset ct ?_ (map 'vector 'identity ":="))
    ct
    ))

(define-derived-mode ucode-mode
    nil "Microcode"
    "Major mode for editing PDP-10 microcode
\\{ucode-mode-map}"
    (setq font-lock-defaults
          '(ucode-mode-keywords
            nil                         ; syntax too
            t                           ; Not case-sensitive
            ((?\; . "<")
             (?\n . ">")
             (?\" . "|"))
            ))
    (setq buffer-display-table ucode-display-table)
    (setq case-fold-search nil))

; syntax table: ucode-mode-syntax-table
; keymap: ucode-mode-map

(provide 'ucode)

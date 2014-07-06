(define-derived-mode rfc-mode fundamental-mode
  "RFC"
  ""
  (narrow-to-page))

(define-key rfc-mode-map
    [left]
  (lambda ()
    (interactive)
    (narrow-to-page -1)
    (goto-char (point-min))))
(define-key rfc-mode-map
    [right]
  (lambda ()
    (interactive)
    (narrow-to-page 1)))

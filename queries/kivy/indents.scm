[
  (block)
  (multiline_expression)
] @indent.begin

; Delimited property expressions deliberately stay flat. Their opening
; delimiter, contents, dictionaries, and closing delimiter share one indent.
(empty_property
  ":" @indent.begin
  (#set! indent.immediate 1))

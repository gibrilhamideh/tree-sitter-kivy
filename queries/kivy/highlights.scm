
(comment) @comment

(section
  [
    (section_leading_comment)
    (section_marker)
    (section_name)
    (section_continuation)
  ] @comment.todo)

(directive) @keyword.directive

(rule
  (selector
    name: (class_name) @type))

(selector
  base: (class_name) @type)

(widget
  name: (class_name) @type)

(canvas_name) @keyword

(inline_property
  name: (property_name) @property)

(multiline_property
  name: (property_name) @property)

(property_block
  name: (property_name) @property)

(empty_property
  name: (property_name) @property)

(number) @number
(string) @string
(operator) @operator
(indentation_error) @error

[
  "<"
  ">"
  "@"
] @punctuation.special

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

[
  ","
  "."
  ":"
  ";"
] @punctuation.delimiter


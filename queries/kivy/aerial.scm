(rule
  (selector) @name
  (#set! "kind" "Class")) @symbol

(section
  name: (section_name) @name
  (#set! "kind" "Namespace")) @symbol

(widget
  name: (class_name) @name
  (#set! "kind" "Constructor")) @symbol

(canvas_block
  name: (canvas_name) @name
  (#set! "kind" "Namespace")) @symbol

(inline_property
  name: (property_name) @name
  (#set! "kind" "Property")) @symbol

(multiline_property
  name: (property_name) @name
  (#set! "kind" "Property")) @symbol

(property_block
  name: (property_name) @name
  (#set! "kind" "Property")) @symbol

(empty_property
  name: (property_name) @name
  (#set! "kind" "Property")) @symbol

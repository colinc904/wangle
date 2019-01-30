import nre

let
  DOC_HEADER*   = re"^@$"
  CODE_HEADER*  = re"^<<([^>]+)>>=$"
  CODE_INCLUDE* = re"^(.*)<<([^>]+)>>(.*)$"

# <<LICENCE>>

type ResultKind* = enum
  simple,
  inclusion

type TangleResult* = object
  case kind*: ResultKind
  of simple:
    text*: string
  of inclusion:
    line*:    int
    indent*:  string
    name*:    string
    postfix*: string


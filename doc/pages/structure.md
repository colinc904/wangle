@page structure Structure Diagram

@startuml

class Chunk {
  line
  name
  body
  newChunk(line, name)
  isCode()
  add(text)
  doc(output)
  code(context, output)
  inclusions()
}

class Clump {
  chunks
  includedBy
  initClump()
  add(chunk)
  write(context, output)
  inclusions()
  includedBy(name)
  isRoot()
}

class Code {
  clumps
  initCode()
  add(chunk)
  digest()
  write(name, context, output)
  roots()
}

class Context {
  name
  line
  indent
  context
  newContext(name, line, indent, context)
  contains(name)
  trace(context, msg)
}

class Doc {
  chunks
  initDoc()
  read(input)
  write(output)
  items()
}

class Inclusion {
  name
  line
  indent
  trace(name)
}

class Web {
  doc
  code
  initWeb()
  read(input)
  digest()
  doc(output)
  code(name, output)
  roots()
}

Clump o-- Chunk
Clump *-- Inclusion

Code *-- Clump
Code *-- Context

Doc *-- Chunk

Web *-- Code

Web *-- Doc
Web *-- Context

@enduml

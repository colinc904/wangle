@page structure Structure Diagram

@startuml

class Chunk {
  line
  name
  body
  add(text)
  inclusions()
  isCode()
  newChunk(line, name)
  tangle()
  weave(output)
}

class Clump {
  chunks
  includers
  add(chunk)
  includedBy(includer)
  inclusions()
  isRoot()
  newClump()
  tangle()
}

class Web {
  doc
  code
  digest()
  newWeb()
  read(input)
  roots()
  tangle(name, output)
  tangleClump(name, context, output)
  weave(output)
}

Clump o-- Chunk

Web *-- Clump 
Web *-- Chunk

@enduml

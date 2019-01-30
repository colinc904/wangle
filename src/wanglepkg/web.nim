import nre
import streams
import strformat
import tables

import chunk
import clump
import tangleresult
import patterns

type Web* = ref object
  doc: seq[Chunk]
  code: TableRef[string, Clump]

type Context = ref object
  name: string
  line: int
  indent: string
  context: Context

proc newContext(
  name: string,
  line: int,
  indent: string = "",
  context: Context = nil
): Context =
  new(result)
  result.name = name
  result.line = line
  result.indent = indent
  result.context = context

proc contains*(self: Context, name: string): bool =
  if self.name == name:
    return true
  elif self.context.isNil:
    return false
  else:
    return self.context.contains(name)
proc newWeb*(): Web =
  new(result)
  result.doc = @[]
  result.code = newTable[string, Clump]();

proc read*(self: Web, input: Stream) =
  var line = 1
  var current = newChunk(line)
  self.doc.add(current)
  while not atEnd(input):
    let text = input.readLine()
    let docChunk = text.match(DOC_HEADER)
    let codeChunk = text.match(CODE_HEADER)
    if isSome(docChunk):
      current = newChunk(line)
      self.doc.add(current)
    elif isSome(codeChunk):
      current = newChunk(line + 1, get(codeChunk).captures[0])
      self.doc.add(current)
    else:
      current.add(text)
    line += 1

proc digest*(self: Web) =
  for chunk in self.doc:
    if chunk.isCode:
      if chunk.name notin self.code:
        self.code[chunk.name] = newClump()
      self.code[chunk.name].add(chunk)
  for includer, clump in self.code:
    for includee in clump.inclusions:
      if includee in self.code:
        self.code[includee].includedBy(includer)

proc weave*(self: Web, output: Stream) =
  for chunk in self.doc:
    chunk.weave(output)

proc tangleClump(
  self: Web,
  name: string,
  context: Context,
  output: Stream
) =
  for item in self.code[name].tangle():
    case item.kind
    of simple:
      output.writeLine(context.indent & item.text)
    of inclusion:
      if item.name in context:
        raise newException(Exception, &"recursive incluing {item.name}")
      let nestedContext = newContext(
        item.name,
        item.line,
        context.indent & item.indent,
        context
      )
      self.tangleClump(item.name, nestedContext, output)


proc tangle*(self: Web, name: string, output: Stream) =
  let rootContext = newContext(name, 0, "")
  self.tangleClump(name, rootContext, output)

iterator roots*(self: Web): string =
  for name, clump in self.code:
    if self.code[name].isRoot:
      yield name
  

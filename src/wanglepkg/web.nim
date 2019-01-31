# This is free and unencumbered software released into the public domain.
# 
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
# 
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
# 
# For more information, please refer to <http://unlicense.org>

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

iterator roots*(self: Web): string =
  for name, clump in self.code:
    if self.code[name].isRoot:
      yield name
  
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

proc weave*(self: Web, output: Stream) =
  for chunk in self.doc:
    chunk.weave(output)


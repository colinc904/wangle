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
# import nre
import sets
import streams
import strformat
import strutils
import tables

import clump
import chunk
import patterns
type WangleError* = object of Exception
type Context* = ref object
  prefix*: string
  name*:   string
  suffix*: string
  line:    int
  context: Context

proc info(self: Context): string
proc newContext(name: string): Context =
  new(result)
  result.prefix  = ""
  result.name    = name
  result.suffix  = ""
  result.context = nil

proc newContext(
  line:    int,
  match:   RegexMatch,
  context: Context
): Context =
  new(result)
  result.line    = line
  result.context = context
  result.prefix  = context.prefix & match.captures["prefix"]
  result.name    = match.captures["name"]
  result.suffix  = match.captures["suffix"] & context.suffix

proc contains*(self: Context, name: string): bool =
  if name == self.name:
    result = true
  elif self.context == nil:
    result = false
  else:
    result = self.context.contains(name)

iterator traceback*(self: Context): string =
  yield self.info
  var context = self.context
  while context.context != nil:
    yield context.info
    context = context.context

proc info(self: Context): string =
  result = &"included in <{self.context.name}> at line {self.line}"

type Web* = ref object
  doc:  seq[Chunk]
  code*: Table[string, Clump]

proc newWeb*(): Web
proc read*(self: Web, input: Stream)
proc gatherClumps(self: Web)
proc tangleClump(self: Web, context: Context, output: Stream)


proc `[]`*(self: Web, name: string): Clump =
  if name notin self.code:
    self.code[name] = newClump()
  result = self.code[name]

proc contains*(self: Web, name: string): bool =
  result = self.code.contains(name)

proc newWebFrom*(input: Stream): Web =
  result = newWeb()
  result.read(input)
  result.gatherClumps()

proc newWeb*(): Web =
  new(result)
  result.doc = newSeq[Chunk]()
  result.code = initTable[string, Clump]()

proc read*(self: Web, input: Stream) =
  var line = 1
  var current = newChunk(line)
  self.doc.add(current)

  while not atEnd(input):
    let text = input.readLine()
    let docChunk = text.match(CODE_TRAILER)
    let codeChunk = text.match(CODE_HEADER)

    if isSome(docChunk):
      current = newChunk(line)
      self.doc.add(current)

    elif isSome(codeChunk):
      current = newChunk(line + 1, get(codeChunk).captures["name"])
      self.doc.add(current)

    else:
      current.add(text)

    line += 1

proc gatherClumps(self: Web) =
  for chunk in self.doc:
    if chunk.isCode:
      self[chunk.name].add(chunk)

iterator roots*(self: Web): string =
  for includer, clump in self.code:
    for line, includee in clump.inclusions:
      self.code[includee].included += 1
  for name, clump in self.code:
    if clump.included == 0:
      yield name

proc weave*(self: Web, output: Stream) =
  for chunk in self.doc:
    chunk.weave(output)

proc tangle*(self: Web, name: string, output: Stream) =

  if name notin self.code:
    raise newException(WangleError, &"<{name}> not found")

  self.tangleClump(newContext(name), output)

proc tangleClump(
  self:    Web,
  context: Context,
  output:  Stream
) =
  for line, text in self[context.name]:

    let codeInclude = text.match(CODE_INCLUDE)
    if isSome(codeInclude):
      let match = get(codeInclude)
      let includee = match.captures["name"]
      if includee in context:
        var message = @[
          &"circular inclusion of <{includee}>",
          &"included in <{context.name}> at line {line}"
        ]
        for text in context.traceback:
          message.add(text)
        raise newException(WangleError, strutils.join(message, "\n"))
        
      else:
        self.tangleClump(newContext(line, match, context), output)
    else:
      output.writeLine(context.prefix & text & context.suffix)


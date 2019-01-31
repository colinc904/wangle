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
import patterns
import tangleresult

type Chunk* = ref object
  line:  int
  name*: string
  body:  seq[string]

proc newChunk*(line: int, name: string = ""): Chunk =
  new(result)
  result.line = line
  result.name = name
  result.body = @[]

proc isCode*(self: Chunk): bool =
  result = (len(self.name) > 0)

proc add*(self: Chunk, text: string) =
  self.body.add(text)

iterator inclusions*(self: Chunk): string =
  for line in self.body:
    let codeInclude = line.match(CODE_INCLUDE)
    if isSome(codeInclude):
      yield get(codeInclude).captures[1]

iterator tangle*(self: Chunk): TangleResult =
  var line = self.line
  for text in self.body:
    let codeInclude = text.match(CODE_INCLUDE)
    if isSome(codeInclude):
      yield TangleResult(
        kind:    inclusion,
        line:    line,
        indent:  get(codeInclude).captures[0],
        name:    get(codeInclude).captures[1],
        postfix: get(codeInclude).captures[2]
      )
    else:
      yield TangleResult(
        kind: simple,
        text: text
      )
    line += 1

proc weave*(self: Chunk, output: Stream) =
  if self.isCode:
    output.writeLine("```\n<" & "<" & self.name & ">>=")
  for line in self.body:
    output.writeLine(line)
  if self.isCode:
    output.writeLine("```")


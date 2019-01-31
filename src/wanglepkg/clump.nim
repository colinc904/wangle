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

import sets
import streams

import chunk
import tangleresult
import patterns

type Clump* = ref object
  chunks:    seq[Chunk]
  includers: HashSet[string]

proc newClump*(): Clump =
  new(result)
  result.chunks = @[]
  result.includers.init()

proc add*(self: Clump, chunk: Chunk) =
  self.chunks.add(chunk)

iterator inclusions*(self: Clump): string =
  for chunk in self.chunks:
    for name in chunk.inclusions:
      yield name

proc includedBy*(self: Clump, includer: string) =
  self.includers.incl(includer)

proc isRoot*(self: Clump): bool =
  result = (len(self.includers) == 0)

iterator tangle*(self: Clump): TangleResult =
  for chunk in self.chunks:
    for whatever in chunk.tangle():
      yield whatever


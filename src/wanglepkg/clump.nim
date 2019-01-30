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

iterator tangle*(self: Clump): TangleResult =
  for chunk in self.chunks:
    for whatever in chunk.tangle():
      yield whatever

proc isRoot*(self: Clump): bool =
  result = (len(self.includers) == 0)


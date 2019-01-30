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

proc weave*(self: Chunk, output: Stream) =
  if self.isCode:
    output.writeLine(&"```\n<<{self.name}>>=")
  for line in self.body:
    output.writeLine(line)
  if self.isCode:
    output.writeLine(&"```")

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


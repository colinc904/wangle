# The implementation of wangle

```
<<LICENCE>>=
blah blah
blah
```

## Structure of a Literate Program

```
<<patterns>>=
DOC_HEADER*   = re"^@$"
CODE_HEADER*  = re"^<<([^>]+)>>=$"
CODE_INCLUDE* = re"^(.*)<<([^>]+)>>(.*)$"
```


## Command-Line Interface

```
<<usage>>=
const doc = """
wangle - a minimal Literate Programming tool in the style of noweb

Usage:
  wangle weave WEB [OUTPUT]
  wangle tangle WEB CHUNK [OUTPUT]
  wangle roots WEB
  wangle [options]

Options:
  -h, --help    Show this message
"""

```

## Object Structure

```
<<web>>=
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
```

```
<<clump>>=
type Clump* = ref object
  chunks:    seq[Chunk]
  includers: HashSet[string]

proc newClump*(): Clump =
  new(result)
  result.chunks = @[]
  result.includers.init()

proc add*(self: Clump, chunk: Chunk) =
  self.chunks.add(chunk)

```

```
<<chunk>>=
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

```

```
<<tangleresult>>=
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

```
## Initialisation

```
<<cli>>=
let args = docopt(doc)

if args["WEB"]:
  <<handle web-related commands>>

```

```
<<handle web-related commands>>=
let filename = $(args["WEB"])
let input = newFileStream(filename)
if isNil(input):
  raise newException(IOError, &"failed to open {filename}")
let theWeb = newWeb()
theWeb.read(input)
theWeb.digest()
close(input)

```

```
<<web>>=
proc newWeb*(): Web =
  new(result)
  result.doc = @[]
  result.code = newTable[string, Clump]();

```

```
<<web>>=
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

```

```
<<web>>=
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

```

```
<<chunk>>=
proc add*(self: Chunk, text: string) =
  self.body.add(text)

```

```
<<clump>>=
iterator inclusions*(self: Clump): string =
  for chunk in self.chunks:
    for name in chunk.inclusions:
      yield name

```

```
<<chunk>>=
iterator inclusions*(self: Chunk): string =
  for line in self.body:
    let codeInclude = line.match(CODE_INCLUDE)
    if isSome(codeInclude):
      yield get(codeInclude).captures[1]

```

```
<<clump>>=
proc includedBy*(self: Clump, includer: string) =
  self.includers.incl(includer)

```

# Scenarios

## Weave

```
<<handle web-related commands>>=
if args["weave"]:
  var filename: string

  if args["OUTPUT"]:
    filename = $(args["OUTPUT"])
  else:
    filename = changeFileExt(extractFilename($(args["WEB"])), "md")

  let output = newFileStream(filename, fmWrite)
  if isNil(output):
    raise newException(IOError, &"failed to open {filename}")
  the_web.weave(output)
  close(output)
  
```

```
<<web>>=
proc weave*(self: Web, output: Stream) =
  for chunk in self.doc:
    chunk.weave(output)

```


```
<<chunk>>=
proc weave*(self: Chunk, output: Stream) =
  if self.isCode:
    output.writeLine(&"```\n<<{self.name}>>=")
  for line in self.body:
    output.writeLine(line)
  if self.isCode:
    output.writeLine(&"```")

```

## Tangle

```
<<handle web-related commands>>=
if args["tangle"]:
  var filename: string

  if args["OUTPUT"]:
    filename = $(args["OUTPUT"])
  else:
    filename = $(args["CHUNK"])

  let output = newFileStream(filename, fmWrite)
  if isNil(output):
    raise newException(IOError, &"failed to open {filename}")
  the_web.tangle($args["CHUNK"], output)
  close(output)
  
```

```
<<web>>=
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

```

```
<<clump>>=
iterator tangle*(self: Clump): TangleResult =
  for chunk in self.chunks:
    for whatever in chunk.tangle():
      yield whatever

```

```
<<chunk>>=
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

```


## roots

```
<<handle web-related commands>>=
if args["roots"]:
  for name in theWeb.roots:
    stdout.writeLine(name)

```

```
<<web>>=
iterator roots*(self: Web): string =
  for name, clump in self.code:
    if self.code[name].isRoot:
      yield name
  
```

```
<<clump>>=
proc isRoot*(self: Clump): bool =
  result = (len(self.includers) == 0)

```

# Odds and Sods

```
<<cli.nim>>=
import ospaths
import streams
import strformat
import docopt

import wanglepkg/chunk
import wanglepkg/web

<<usage>>
<<cli>>
```

```
<<chunk.nim>>=
import nre
import streams
import strformat
import patterns
import tangleresult

<<chunk>>
```

```
<<clump.nim>>=
import sets
import streams

import chunk
import tangleresult
import patterns

<<clump>>
```


```
<<web.nim>>=
import nre
import streams
import strformat
import tables

import chunk
import clump
import tangleresult
import patterns

<<web>>
```

```
<<patterns.nim>>=
import nre

let
  <<patterns>>
```

```
<<tangleresult.nim>>=
# <<LICENCE>>

<<tangleresult>>
```


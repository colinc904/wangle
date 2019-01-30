import ospaths
import streams
import strformat
import docopt

import wanglepkg/chunk
import wanglepkg/web

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

let args = docopt(doc)

if args["WEB"]:
  let filename = $(args["WEB"])
  let input = newFileStream(filename)
  if isNil(input):
    raise newException(IOError, &"failed to open {filename}")
  let theWeb = newWeb()
  theWeb.read(input)
  theWeb.digest()
  close(input)
  
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
    
  if args["roots"]:
    for name in theWeb.roots:
      stdout.writeLine(name)
  


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
import ospaths
import streams
import strformat
import docopt
import wanglepkg/web


const usage = """
wangle - a minimal Literate Programming tool in the style of noweb

Usage:
  wangle weave WEB [OUTPUT]
  wangle tangle WEB CHUNK [OUTPUT]
  wangle roots WEB
  wangle [options]

Options:
  -h, --help    Show this message
"""


try:
  var theWeb: Web
  let args = docopt(usage)
  if args["WEB"]:
    let filename = $(args["WEB"])
    let input = newFileStream(filename)
    if input.isNil:
      raise newException(WangleError, &"failed to open {filename}")
    theWeb = newWebFrom(input)
    close(input)
  
  if args["roots"]:
    for name in theWeb.roots:
      stdout.writeLine(name)
  
  if args["weave"]:
    var filename: string
  
    if args["OUTPUT"]:
      filename = $(args["OUTPUT"])
    else:
      filename = changeFileExt(ospaths.extractFilename($(args["WEB"])), "md")
  
    let output = newFileStream(filename, fmWrite)
    if isNil(output):
      raise newException(WangleError, &"failed to open {filename}")
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
      raise newException(WangleError, &"failed to open {filename}")
  
    the_web.tangle($args["CHUNK"], output)
  
    close(output)
    
  quit(QuitSuccess)

except WangleError:
  stderr.write(getCurrentExceptionMsg())
  quit(QuitFailure)

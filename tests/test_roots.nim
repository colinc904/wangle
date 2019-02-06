#tests/test_roots.nim

import sequtils
import streams
import tables
import sets
import unittest
import wanglepkg/web

let inputstr = """
t1
<<a>>=
c1
<<b>>
c2
@
t2
<<b>>=
c3
@
"""

suite "roots":
  test "ummm":
    var input = newStringStream(inputstr)
    var theWeb = newWebFrom(input)
    var roots = sequtils.toSeq(theWeb.roots)
   
    #for name, clump in theWeb.code:
    #  echo name, len(clump.includers)

    check "a" in roots
    check "b" notin roots


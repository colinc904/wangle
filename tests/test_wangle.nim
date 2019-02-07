# tests/test_wangle.nim

import nre except toSeq
import sequtils
import streams
import unittest

import wanglepkg/patterns
import wanglepkg/web

suite "CODE_INCLUDE":
  test "bad":
    let input = "rubbish"
    let m = input.match(CODE_INCLUDE)
    check isNone(m)

  test "n":
    let input = "<<x>>"
    let m = input.match(CODE_INCLUDE)
    check isSome(m)
    check get(m).captures["prefix"] == ""
    check get(m).captures["name"] == "x"
    check get(m).captures["suffix"] == ""

suite "roots":
  test "ummm":
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

    var input = newStringStream(inputstr)
    var theWeb = newWebFrom(input)
    var roots = sequtils.toSeq(theWeb.roots)
   
    check "a" in roots
    check "b" notin roots


# tests/test_wangle.nim

import osproc
import sequtils
import strutils
import streams
import unittest

import wanglepkg/patterns
import wanglepkg/web
import wanglepkg/chunk
import wanglepkg/clump

proc newWebFrom(lines: seq[string]): Web =
  result = newWebFrom(newStringStream(strutils.join(lines, "\n")))

suite "cli":
  test "help message":
     check "Usage" in execProcess("./wangle -h")
     check "Usage" in execProcess("./wangle --help")

suite "patterns":
  test "CODE_INCLUDE bad":
    let input = "rubbish"
    let m = input.match(CODE_INCLUDE)
    check isNone(m)

  test "CODE_INCLUDE n":
    let input = "<<x>>"
    let m = input.match(CODE_INCLUDE)
    check isSome(m)
    check get(m).captures["prefix"] == ""
    check get(m).captures["name"] == "x"
    check get(m).captures["suffix"] == ""

suite "roots":
  test "roots":
    var theWeb = newWebFrom(@[
        "t1",
        "<<a>>=",
        "c1",
        "<<b>>",
        "c2",
        "@",
        "t2",
        "<<b>>=",
        "c3",
        "@"
      ])
    var roots = sequtils.toSeq(theWeb.roots)
   
    check "a" in roots
    check "b" notin roots

suite "weave":
  test "doc chunk":
    let theWeb = newWebFrom(@[
      "a",
      "b"
    ])
    let output = newStringStream()
    theWeb.weave(output)
    check output.data == strutils.join([
      "a",
      "b",
      ""
    ],"\n")

  test "simple code chunk":
    let theWeb = newWebFrom(@[
      "<<c>>=",
      "x = 0",
      "@"
    ])
    let output = newStringStream()
    theWeb.weave(output)
    check output.data == strutils.join([
      "```",
      "<<c>>=",
      "x = 0",
      "```",
      ""
    ],"\n")

  test "code chunk with include":
    let theWeb = newWebFrom(@[
      "<<c>>=",
      "x = 0",
      "<<d>>",
      "@"
    ])
    let output = newStringStream()
    theWeb.weave(output)
    check output.data == strutils.join([
      "```",
      "<<c>>=",
      "x = 0",
      "<<d>>",
      "```",
      ""
    ],"\n")

suite "tangle":
  test "plain text":
    let theWeb = newWebFrom(@[
      "a",
      "<<b>>=",
      "c",
      "d",
      "@",
      "e"
    ])
    let output = newStringStream()
    theWeb.tangle("b", output)
    check output.data == strutils.join(@[
      "c",
      "d",
      ""
    ],"\n")

  test "prefix and suffix":
    let theWeb = newWebFrom(@[
      "<<a>>=",
      "  (<<b>>)",
      "@",
      "<<b>>=",
      "[<<c>>]",
      "@",
      "<<c>>=",
      "d",
      "e",
      "@"
    ])
    let output = newStringStream()
    theWeb.tangle("a", output)
    check output.data == strutils.join(@[
      "  ([d])",
      "  ([e])",
      "",
    ],"\n")


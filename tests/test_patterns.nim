# tests/test_patterns.nim

import unittest
import nre

import wanglepkg/patterns

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

import unittest
import tables
import sequtils
import sets

import propositionalLogic

suite "test for hashing":
  let
    P = generateAtomicProp()
    Q = generateAtomicProp()
    formula1 = P => Q
    formula2 = !P | Q
    formula3 = P & Q
    table = {formula1: TOP, formula2: BOTTOM}.toTable
  
  test "get keys":
    let keys = table.keys().toSeq
    check keys.len == 2
    check keys.contains(formula1)
    check keys.contains(formula2)
    check not keys.contains(formula3)
  
  test "get values":
    check table[formula1] == TOP
    check table[formula2] == BOTTOM
  
  test "test for hash sets":
    let keys = table.keys().toSeq().toHashSet()
    check keys.contains(formula1)
    check keys.contains(formula2)
    check not keys.contains(formula3)
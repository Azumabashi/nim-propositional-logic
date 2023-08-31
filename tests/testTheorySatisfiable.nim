import unittest
import tables

import propositionalLogic

suite "check satisfiablity for theory":
  setup:
    let 
      P = generateAtomicProp()
      Q = generateAtomicProp()
      R = generateAtomicProp()
  
  test "theory contains only atomic formulae":
    let 
      theory = @[P, Q, R]
      interpretation = {
        P: TOP,
        Q: TOP,
        R: TOP
      }.toTable
    check theory.isSat(interpretation)
  
  test "theory contains compound formulae":
    let 
      theory = @[P => Q, !Q => P | R, P & R]
      interpretation = {
        P: TOP,
        Q: TOP,
        R: TOP
      }.toTable
    check theory.isSat(interpretation)
  
  test "theory contains formulae with contradiction":
    let 
      theory = @[P, !P]
    check theory.isContradiction()
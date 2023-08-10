import unittest
import tables

import propositionalLogic

suite "check satisfiablity for theory":
  setup:
    let 
      (allFormulae, allInterpretations) = init(3)
      P = allFormulae[0]
      Q = allFormulae[1]
      R = allFormulae[2]
  
  test "theory contains only atomic formulae":
    let 
      theory = @[P, Q, R]
      interpretation = {
        P.id: TOP,
        Q.id: TOP,
        R.id: TOP
      }.toTable
    check theory.isSat(interpretation)
  
  test "theory contains compound formulae":
    let 
      theory = @[P => Q, !Q => P | R, P & R]
      interpretation = {
        P.id: TOP,
        Q.id: TOP,
        R.id: TOP
      }.toTable
    check theory.isSat(interpretation)
  
  test "theory contains formulae with contradiction":
    let 
      theory = @[P, !P]
    for interpretation in allInterpretations:
      check not theory.isSat(interpretation)
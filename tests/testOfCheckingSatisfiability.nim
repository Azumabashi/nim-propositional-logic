import unittest

import propositionalLogic
suite "check satisfiability under specific interpretation":
  setup:
    let 
      P = generateAtomicProp()
      Q = generateAtomicProp()
      R = generateAtomicProp()
  
  test "excluded middle law":
    let formula = P | (!P)
    check formula.isTautology()
  
  test "unsat formula":
    let formula = P & (!P)
    check formula.getModels().len == 0
  
  test "satisfiable formula":
    let formula = P & (Q => (!R))
    check formula.getModels().len > 0
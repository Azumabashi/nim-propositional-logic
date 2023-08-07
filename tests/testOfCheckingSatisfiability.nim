import unittest
import sets
import sequtils

import propositionalLogic
suite "check satisfiability under specific interpretation":
  setup:
    let 
      P = generateAtomicProp()
      Q = generateAtomicProp()
      R = generateAtomicProp()
      allProps = @[P, Q, R]
      allInterpretations = allProps.mapIt(it.id).toHashSet.getAllInterpretations()
  
  test "excluded middle law":
    let formula = P | (!P)
    check formula.isTautology(allInterpretations)
  
  test "unsat formula":
    let formula = P & (!P)
    check formula.getModels(allInterpretations).len == 0
  
  test "satisfiable formula":
    let formula = P & (Q => (!R))
    check formula.getModels(allInterpretations).len > 0
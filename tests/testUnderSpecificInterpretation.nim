import unittest
import tables

import propositionalLogic
suite "check satisfiability under specific interpretation":
  setup:
    let 
      P = generateAtomicProp()
      Q = generateAtomicProp()
      interpretation = {
        P: TOP,
        Q: BOTTOM
      }.toTable
  
  test "excluded middle law":
    let formula = P | (!P)
    check formula.isSat(interpretation)
  
  test "and":
    let formula = P & Q
    check not formula.isSat(interpretation)
  
  test "or":
    let formula = P | Q
    check formula.isSat(interpretation)
  
  test "not":
    let formula = !Q
    check formula.isSat(interpretation)
  
  test "implies":
    let formula = Q => P
    check formula.isSat(interpretation)
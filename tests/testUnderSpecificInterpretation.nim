import unittest
import tables

import propositionalLogic
suite "check satisfiability under specific interpretation":
  setup:
    let 
      interpretation = {
        1: TOP,
        2: BOTTOM
      }.toTable
      P = generateAtomicProp(1)
      Q = generateAtomicProp(2)
  
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
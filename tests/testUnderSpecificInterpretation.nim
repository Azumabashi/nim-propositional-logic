import unittest
import tables

import propositionalLogic
suite "check satisfiability under specific interpretation":
  setup:
    let 
      (allFormulae, _) = init(2)
      P = allFormulae[0]
      Q = allFormulae[1]
      interpretation = {
        P.id: TOP,
        Q.id: BOTTOM
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
import unittest

import propositionalLogic
suite "check satisfiability under specific interpretation":
  setup:
    let 
      (allFormulae, allInterpretations) = init(3)
      P = allFormulae[0]
      Q = allFormulae[1]
      R = allFormulae[2]
  
  test "excluded middle law":
    let formula = P | (!P)
    check formula.isTautology(allInterpretations)
  
  test "unsat formula":
    let formula = P & (!P)
    check formula.getModels(allInterpretations).len == 0
  
  test "satisfiable formula":
    let formula = P & (Q => (!R))
    check formula.getModels(allInterpretations).len > 0
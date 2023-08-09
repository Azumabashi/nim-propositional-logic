import unittest

import propositionalLogic

suite "check formula equivalance":
  setup:
    let
      (formulae, _) = init(2)
      P = formulae[0]
      Q = formulae[1]
  
  test "P == P":
    check P == P
  
  test "and":
    check (P & Q) == (P & Q)
  
  test "or":
    check (P | Q) == (P | Q)
  
  test "not":
    check !P == !P
  
  test "implies":
    check (P => Q) == (P => Q)
  
  test "logical equivalence but different formula":
    check not ((P => Q) == ((!P) | Q))
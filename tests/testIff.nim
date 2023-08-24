import unittest

import propositionalLogic

suite "check whether `iff` works correctly or not":
  let
    P = generateAtomicProp()
    Q = generateAtomicProp()
  
  test "implies":
    let
      formula1 = P => Q
      formula2 = !P | Q
    check formula1.iff(formula2)
  
  test "De Morgan's laws":
    let
      formula1 = P & Q
      formula2 = !(!P | !Q)
    check formula1.iff(formula2)
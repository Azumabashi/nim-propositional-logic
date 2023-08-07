import unittest
import tables

import propositionalLogic
suite "check satisfiability under specific interpretation":
  setup:
    let 
      P = generateAtomicProp()
      Q = generateAtomicProp()
      R = generateAtomicProp()
  
  test "excluded middle law":
    let formula = P | (!P)
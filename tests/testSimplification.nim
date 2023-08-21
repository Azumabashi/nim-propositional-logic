import unittest

import propositionalLogic

suite "make logical formula simple":
  # test case is taken from https://en.wikipedia.org/wiki/Quine%E2%80%93McCluskey_algorithm
  # (as of 2023/08/21)
  setup:
    let 
      A = generateAtomicProp()
      B = generateAtomicProp()
      C = generateAtomicProp()
      D = generateAtomicProp()
    let
      formula = (!A & B & !C & !D) | (A & !B & !C & !D) | (A & !B & C & !D) | (A & !B & C & D) | (A & B & !C & !D)  | (A & B & C & D)
      simplerFormula = formula.simplification()
  
  test "checking logical equivalence":
    echo (formula => simplerFormula).isTautology() and (simplerFormula => formula).isTautology()
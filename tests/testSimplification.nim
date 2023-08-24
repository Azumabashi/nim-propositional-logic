import unittest

import propositionalLogic

suite "make logical formula simple":
  # test case is taken from https://en.wikipedia.org/wiki/Quine%E2%80%93McCluskey_algorithm
  # (as of 2023/08/21)
  let 
    A = generateAtomicProp()
    B = generateAtomicProp()
    C = generateAtomicProp()
    D = generateAtomicProp()
  
  test "checking logical equivalence":
    let
      formula = (!A & B & !C & !D) | (A & !B & !C & !D) | (A & !B & C & !D) | (A & !B & C & D) | (A & B & !C & !D)  | (A & B & C & D)
      simplerFormula = formula.simplification()
    check (formula => simplerFormula).isTautology() and (simplerFormula => formula).isTautology()
import unittest

import
  propositionalLogic,
  tables

suite "parse formulae":
  let
    p = generateAtomicProp()
    q = generateAtomicProp()
    r = generateAtomicProp()
    t = {"p": p, "q": q, "r": r}.toTable
  
  test "single formula":
    assert "p".parse(t)[0].iff(p)
  
  test "formula with only one NOT":
    assert "(!p)".parse(t)[0].iff(!p)
  
  test "formula with only one IMPLIES":
    assert "(p => q)".parse(t)[0].iff(p => q)
  
  test "formula with only one AND":
    assert "(p & q)".parse(t)[0].iff(p & q)
  
  test "formula with only one OR":
    assert "(p | q)".parse(t)[0].iff(p | q)
  
  test "complex formulae":
    assert "(p & (q & r))".parse(t)[0].iff(p & q & r)
    assert "((!p) & (!(q | r)))".parse(t)[0].iff(!p & !(q | r))
    assert "(p => ((!q) & r))".parse(t)[0].iff(p => (!q & r))
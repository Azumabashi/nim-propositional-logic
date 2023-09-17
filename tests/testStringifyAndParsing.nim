import unittest
import strformat

import propositionalLogic

suite "Stringify and restoring":
  let 
    p = generateAtomicProp()
    q = generateAtomicProp()
    r = generateAtomicProp()
    formula = !p => (p | (q & r))
  
  test "stringify":
    let
      pId = p.getId()
      qId = q.getId()
      rId = r.getId()
    assert $formula == fmt"((!{pId})=>({pId}|({qId}&{rId})))"
  
  test "restoring":
    let restored = ($formula).parse()
    assert restored == formula
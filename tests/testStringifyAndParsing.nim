import unittest
import strformat
import tables
import sets
import sequtils

import propositionalLogic

suite "Stringify and restoring":
  let 
    p = generateAtomicProp()
    q = generateAtomicProp()
    r = generateAtomicProp()
    formula = !p => (p | (q & r))
    pId = p.getId()
    qId = q.getId()
    rId = r.getId()
    nameToAtomicProps = {
      $pId: p,
      $qId: q,
      $rId: r
    }.toTable()
  
  test "stringify":
    assert $formula == fmt"((!{pId})=>({pId}|({qId}&{rId})))"
  
  test "restoring":
    let (restored, newNameToAtomicProps) = ($formula).parse(nameToAtomicProps)
    assert $restored == $formula
    assert newNameToAtomicProps.keys().toSeq().toHashSet() == nameToAtomicProps.keys().toSeq().toHashSet()
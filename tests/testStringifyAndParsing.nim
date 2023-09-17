import unittest
import strformat
import tables
import sets
import sequtils
import strutils

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
  
  test "parse formula which includes atomic propositions which name is non-number":
    var currentNameToAtomicProps = nameToAtomicProps
    # generate atomic proposition corresponds to p before parsing
    currentNameToAtomicProps["p"] = generateAtomicProp()
    let 
      formulaContainsNonNumber = "((p => (!(q & p))) | r)"
      (restored, newNameToAtomicProps) = formulaContainsNonNumber.parse(currentNameToAtomicProps)
      idToNamePair = newNameToAtomicProps.pairs().toSeq().mapIt(($(it[1].getId()), it[0]))
    # remove spaces
    assert ($restored).multiReplace(idToNamePair.concat(@[(" ", "")])) == formulaContainsNonNumber.replace(" ", "")
    assert nameToAtomicProps.keys().toSeq().toHashSet() < newNameToAtomicProps.keys().toSeq().toHashSet()
    assert newNameToAtomicProps.hasKey("p")
    assert newNameToAtomicProps.hasKey("q")
    assert newNameToAtomicProps.hasKey("r")
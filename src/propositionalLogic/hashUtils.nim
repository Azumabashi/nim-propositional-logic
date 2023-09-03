## This module provides proc `hash` for `PropLogicFormula` and `TruthValue` (the algorithm of 
## proc `hash` this module provides can be improved).

import hashes
import formulae
import truthValue

proc hash*(formula: PropLogicFormula): Hash =
  ## Returns hash value of given `formula`.
  !$ recByStructure(
    formula,
    proc (formula: PropLogicFormula): Hash = hash(formula.getId()),
    proc (left, right: Hash): Hash = (left and right).Hash,
    proc (left, right: Hash): Hash = (left or right).Hash,
    proc (antecedent, consequent: Hash): Hash = ((not antecedent) or consequent).Hash,
    proc (val: Hash): Hash = (not val).Hash
  )

proc hash*(truthValue: TruthValue): Hash =
  ## Returns hash value of given `truthValue`.
  if truthValue == TOP: 1.Hash else: 0.Hash
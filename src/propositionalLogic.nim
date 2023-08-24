## This library provides types and procs correspond to standard propositional logic.
## Users want to use this library should understand concepts of it (proposition, logical connective, etc.).
## This document does not include explanations about propositional logic itself.
## 
## **Note that the implementation of procedures this library provides is naive and sometimes inefficient** (exponential time).
## The documentation of such procedures includes notice for "computational complexity".
## If you need to deal with logical formulae with many atomic propositions or too complex logical formulae,
## consider using sat solvers.
runnableExamples:
  import propositionalLogic

  let
    P = generateAtomicProp()
    Q = generateAtomicProp()
    formula = P => (Q | !Q)
  
  echo formula.isTautology()
  ## Output:
  ##   true

import
  propositionalLogic/truthValue,
  propositionalLogic/formulae,
  propositionalLogic/evalUtils,
  propositionalLogic/interpretationUtils,
  propositionalLogic/simplification

# List of types/procs/iterators to be exported
export
  TruthValue, TOP, BOTTOM, `==`, `and`, `or`, `not`,
  PropLogicFormula, generateAtomicProp, generateAtomicPropWithGivenId, `&`, `|`, `=>`, `!`, `$`, recByStructure,
  isSat, getModels, isTautology, isContradiction, iff,
  Interpretation, interpretations, getModels,
  simplification
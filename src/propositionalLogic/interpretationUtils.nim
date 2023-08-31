import tables
import sugar
import truthValue
from formulae import getNumberOfAtomicProps, recByStructure, PropLogicFormula

type
  Interpretation* = Table[int, TruthValue]
    ## Type alias represents interpretation.
    ## The key is id of an atomic proposition.

proc getNumberOfInterpretations*(): int =
  runnableExamples:
    import propositionalLogic

    let
      _ = generateAtomicProp()
      _ = generateAtomicProp()
      _ = generateAtomicProp()
    assert getNumberOfInterpretations() == 8
  ## Returns number of interpretations.
  1 shl getNumberOfAtomicProps()

iterator interpretations*(): Interpretation =
  ## Iterator generates all interpretations to all atomic propositions.
  ## Be careful of computational complexity (O(N * 2^N) where N is the number of
  ## atomic propositions).
  runnableExamples:
    import propositionalLogic

    let
      P = generateAtomicProp()
      Q = generateAtomicProp()
      formula = P => (Q | !Q)
    
    for interpretation in interpretations():
      assert formula.isSat(interpretation)
  ## Note that to check whether a formula is a tautology, satisfiable, or a contradict,
  ## use proc `isTautology`, `isSat`, or `isContradict` respectively.
  let 
    numberOfAtomicProps = getNumberOfAtomicProps()
    numberOfInterpretation = getNumberOfInterpretations()
  for pattern in 0..<numberOfInterpretation:
    var interpretation = initTable[int, TruthValue]()
    for id in 0..<numberOfAtomicProps:
      interpretation[id] = if (pattern and (1 shl id)) > 0: TOP else: BOTTOM
    yield interpretation

proc eval*(formula: PropLogicFormula, interpretation: Interpretation): TruthValue = 
  ## Evaluate `formula` with `interpretation`, and returns `TOP`
  ## if the formula is true under the interpretation and `BOTTOM` otherwise.
  runnableExamples:
    import tables
    import propositionalLogic
    let
      P = generateAtomicProp()
      Q = generateAtomicProp()
      interpretation = {
        P.id: TOP,
        Q.id: BOTTOM
      }.toTable
    assert (P | Q).eval(interpretation) == TOP
  recByStructure(
    formula,
    formula => interpretation[formula.id],
    (left, right) => left and right,
    (left, right) => left or right,
    (antecedent, consequent) => (not antecedent) or consequent,
    val => not val
  )
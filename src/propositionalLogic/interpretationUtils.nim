import tables
import truthValue
import formulae
import hashUtils

type
  Interpretation* = Table[PropLogicFormula, TruthValue]
    ## Type alias represents interpretation.
    ## The keys are atomic propositions.

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
    var interpretation = initTable[PropLogicFormula, TruthValue]()
    for id in 0..<numberOfAtomicProps:
      interpretation[id.generateAtomicPropWithGivenId()] = if (pattern and (1 shl id)) > 0: TOP else: BOTTOM
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
    proc (formula: PropLogicFormula): TruthValue = interpretation[formula],
    proc (left, right: TruthValue): TruthValue = left and right,
    proc (left, right: TruthValue): TruthValue = left or right,
    proc (antecedent, consequent: TruthValue): TruthValue = (not antecedent) or consequent,
    proc (val: TruthValue): TruthValue = not val
  )
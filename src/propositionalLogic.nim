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

import tables
import sequtils
import strformat

type
  PropFormulaType {.pure.} = enum
    atomicProp, andProp, orProp, notProp, impliesProp
  PropLogicFormula* = ref object
    ## Object corresponds to logical formulae.
    ## This object uses a private field to express form (atomic formula, φ∧ψ, φ∨ψ, φ⇒ψ, or ¬φ)
    ## of the logical formula the instance represents.
    # cf. https://github.com/momeemt/minim/blob/main/src/minim/asts.nim#L16-L47
    case formulaType: PropFormulaType
    of PropFormulaType.atomicProp:
      id*: int
    of PropFormulaType.andProp, PropFormulaType.orProp:
      left*, right*: PropLogicFormula
    of PropFormulaType.notProp:
      formula*: PropLogicFormula
    of PropFormulaType.impliesProp:
      antecedent*, consequent*: PropLogicFormula
  TruthVaue* = ref object
    ## Object corresponds to truth value.
    ## Two truth values "True" and "False" are distinguished by the field of this object.
    value*: bool
  Interpretation* = Table[int, TruthVaue]
    ## Type alias represents interpretation.
    ## The key is id of an atomic proposition.

let
  TOP* = TruthVaue(value: true)
    ## Logical constatnt represents `true`.
  BOTTOM* = TruthVaue(value: false)
    ## Logical constant represents `false`.

var
  existingAtomicProps = 0

proc numberOfInterpretations(): int = 1 shl existingAtomicProps

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
    numberOfInterpretation = numberOfInterpretations()
  for pattern in 0..<numberOfInterpretation:
    var interpretation = initTable[int, TruthVaue]()
    for id in 0..<existingAtomicProps:
      interpretation[id] = if (pattern and (1 shl id)) > 0: TOP else: BOTTOM
    yield interpretation

proc `&`* (left, right: PropLogicFormula): PropLogicFormula = 
  ## Logical connective and.
  ## It is recommended to specify connection order with paren.
  runnableExamples:
    let
      P = generateAtomicProp()
      Q = generateAtomicProp()
      R = generateAtomicProp()
      formulae = (P & Q) & R
      ## This is (P and Q) and R
  PropLogicFormula(
    formulaType: PropFormulaType.andProp,
    left: left,
    right: right
  )

proc `|`*(left, right: PropLogicFormula): PropLogicFormula = 
  ## Logical connective or.
  ## It is recommended to specify connection order with paren.
  runnableExamples:
    let
      P = generateAtomicProp()
      Q = generateAtomicProp()
      R = generateAtomicProp()
      formulae = (P | Q) | R
      ## This is (P or Q) or R
  PropLogicFormula(
    formulaType: PropFormulaType.orProp,
    left: left,
    right: right
  )

proc `!`*(formula: PropLogicFormula): PropLogicFormula =
  ## Logical connective not.
  ## It is recommended to specify connection order with parentheses.
  runnableExamples:
    let
      P = generateAtomicProp()
      formulae = !(!P)
      ## This is not (not P)
  PropLogicFormula(
    formulaType: PropFormulaType.notProp,
    formula: formula
  )

proc `=>`*(antecedent, consequent: PropLogicFormula): PropLogicFormula =
  ## Logical connective implies.
  ## It is recommended to specify connection order with parentheses.
  runnableExamples:
    let
      P = generateAtomicProp()
      Q = generateAtomicProp()
      R = generateAtomicProp()
      formulae = P => (Q => R)
      ## This is P implies (Q implies R)
  PropLogicFormula(
    formulaType: PropFormulaType.impliesProp,
    antecedent: antecedent,
    consequent: consequent
  )

proc `==`*(left, right: TruthVaue): bool =
  ## Compare two truth values.
  left.value == right.value

proc `==`*(left, right: PropLogicFormula): bool = 
  ## Compare two logical formulae.
  ## This procedure determines `==` recursively.
  runnableExamples:
    let
      P = generateAtomicProp()
      Q = generateAtomicProp()
    assert (P & Q) == (P & Q)
    assert not ((P & Q) == (Q & P))
    ## Note that (P and Q) and (Q and P) are treated as different formulae.
  if left.formulaType != right.formulaType:
    return false
  case left.formulaType
  of PropFormulaType.atomicProp:
    return left.id == right.id
  of PropFormulaType.andProp, PropFormulaType.orProp:
    return left.left == right.left and left.right == right.right
  of PropFormulaType.notProp:
    return left.formula == right.formula
  of PropFormulaType.impliesProp:
    return left.antecedent == right.antecedent and left.consequent == right.consequent

proc `$`*(formula: PropLogicFormula): string = 
  ## Stringify procedure for `PropLogicFormula`.
  case formula.formulaType
  of PropFormulaType.atomicProp:
    $(formula.id)
  of PropFormulaType.andProp:
    fmt"({formula.left}&{formula.right})"
  of PropFormulaType.orProp:
    fmt"({formula.left}|{formula.right})"
  of PropFormulaType.notProp:
    fmt"(!{formula.formula})"
  of PropFormulaType.impliesProp:
    fmt"({formula.antecedent}=>{formula.consequent})"

proc eval*(formula: PropLogicFormula, interpretation: Interpretation): TruthVaue = 
  ## Evaluate `formula` with `interpretation`, and returns `TOP`
  ## if the formula is true under the interpretation and `BOTTOM` otherwise.
  runnableExamples:
    import tables
    let
      P = generateAtomicProp()
      Q = generateAtomicProp()
      interpretation = {
        P.id: TOP,
        Q.id: BOTTOM
      }.toTable
    assert (P | Q).eval(interpretation) == TOP
  case formula.formulaType
  of PropFormulaType.atomicProp:
    interpretation[formula.id]
  of PropFormulaType.andProp:
    TruthVaue(
      value: formula.left.eval(interpretation) == TOP and formula.right.eval(interpretation) == TOP
    )
  of PropFormulaType.orProp:
    TruthVaue(
      value: formula.left.eval(interpretation) == TOP or formula.right.eval(interpretation) == TOP
    )
  of PropFormulaType.notProp:
    TruthVaue(
      value: formula.formula.eval(interpretation) == BOTTOM
    )
  of PropFormulaType.impliesProp:
    TruthVaue(
      value: formula.antecedent.eval(interpretation) == BOTTOM or formula.consequent.eval(interpretation) == TOP
    )

proc generateAtomicProp*(): PropLogicFormula = 
  ## Generate an atomic proposition.
  result = PropLogicFormula(
    formulaType: PropFormulaType.atomicProp,
    id: existingAtomicProps
  )
  existingAtomicProps += 1

proc concatWithAnd(theory: seq[PropLogicFormula]): PropLogicFormula =
  theory[1..<theory.len].foldl(
    (a & b),
    theory[0]
  )

proc isSat*(formula: PropLogicFormula, interpretation: Interpretation): bool = 
  ## Returns `true` if the given formula is true under the given interpretation and `false` otherwise.
  formula.eval(interpretation) == TOP

proc isSat*(theory: seq[PropLogicFormula], interpretation: Interpretation): bool =
  ## Returns `true` if all formulae included in the given theory becomes true under the given interpretation and `false` otherwise.
  theory.concatWithAnd().isSat(interpretation)

proc getModels*(formula: PropLogicFormula): seq[Interpretation] =
  ## Returns all models to the given `formula`.
  ## Be careful of computational complexity.
  for interpretation in interpretations():
    if formula.isSat(interpretation):
      result.add(interpretation)

proc isSat*(formula: PropLogicFormula): bool =
  ## Returns `true` if the given formula is satisfiable and `false` otherwise.
  ## Be careful of computational complexity.
  formula.getModels().len > 0

proc isSat*(theory: seq[PropLogicFormula]): bool =
  ## Returns `true` if the given theory is satisfiable  (i.e. all formulae
  ## included in the given theory are satisfiable by the same interpretation)
  ## and `false` otherwise.
  ## Be careful of computational complexity.
  theory.concatWithAnd().isSat()

proc isTautology*(formula: PropLogicFormula): bool = 
  ## Returns `true` if the given formula is tautology and `false` otherwise.
  ## Be careful of computational complexity.
  formula.getModels().len == numberOfInterpretations()

proc isContradiction*(formula: PropLogicFormula): bool =
  ## Returns `true` if given the formula contradicts and `false` otherwise.
  ## Be careful of computational complexity.
  formula.getModels().len == 0

proc isContradiction*(theory: seq[PropLogicFormula]): bool =
  ## Returns `true` if the given theory contradicts and `false` otherwise.
  ## Be careful of computational complexity.
  theory.concatWithAnd().getModels().len == 0
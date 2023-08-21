import strformat

# These type definitions should be here because
# PropFormulaType is private.
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

var
  existingAtomicProps = 0

proc getNumberOfAtomicProps*(): int = existingAtomicProps

proc generateAtomicProp*(): PropLogicFormula = 
  ## Generate an atomic proposition.
  result = PropLogicFormula(
    formulaType: PropFormulaType.atomicProp,
    id: existingAtomicProps
  )
  existingAtomicProps += 1

proc `&`* (left, right: PropLogicFormula): PropLogicFormula = 
  ## Logical connective and.
  ## It is recommended to specify connection order with paren.
  runnableExamples:
    let
      P = generateAtomicProp()
      Q = generateAtomicProp()
      R = generateAtomicProp()
      formula = (P & Q) & R
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
      formula = (P | Q) | R
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
      formula = !(!P)
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
      formula = P => (Q => R)
      ## This is P implies (Q implies R)
  PropLogicFormula(
    formulaType: PropFormulaType.impliesProp,
    antecedent: antecedent,
    consequent: consequent
  )

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

proc recByStructure*[T](
  formula: PropLogicFormula,
  atomicCase: proc (formula: PropLogicFormula): T,
  andCase, orCase: proc(left, right: T): T,
  impliesCase: proc(antecedent, consequent: T): T,
  notCase: proc(val: T): T
): T = 
  ## Get value of type `T` with recursion according to given formula's structure.
  ## The proc `eval` is an example of how to use this proc.
  proc recByStructureInner(formula: PropLogicFormula): T =
    case formula.formulaType
    of PropFormulaType.atomicProp:
      formula.atomicCase()
    of PropFormulaType.andProp:
      andCase(
        formula.left.recByStructureInner(),
        formula.right.recByStructureInner()
      )
    of PropFormulaType.orProp:
      orCase(
        formula.left.recByStructureInner(),
        formula.right.recByStructureInner()
      )
    of PropFormulaType.notProp:
      notCase(
        formula.formula.recByStructureInner()
      )
    of PropFormulaType.impliesProp:
      impliesCase(
        formula.antecedent.recByStructureInner(),
        formula.consequent.recByStructureInner()
      )
  result = formula.recByStructureInner()
import tables
import sequtils
import strformat

type
  PropFormulaType {.pure.} = enum
    atomicProp, andProp, orProp, notProp, impliesProp
  PropLogicFormula* = ref object
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
    value*: bool
  Interpretation* = Table[int, TruthVaue]

let
  TOP* = TruthVaue(value: true)
  BOTTOM* = TruthVaue(value: false)

proc `&`* (left, right: PropLogicFormula): PropLogicFormula = 
  PropLogicFormula(
    formulaType: PropFormulaType.andProp,
    left: left,
    right: right
  )

proc `|`*(left, right: PropLogicFormula): PropLogicFormula = 
  PropLogicFormula(
    formulaType: PropFormulaType.orProp,
    left: left,
    right: right
  )

proc `!`*(formula: PropLogicFormula): PropLogicFormula =
  PropLogicFormula(
    formulaType: PropFormulaType.notProp,
    formula: formula
  )

proc `=>`*(antecedent, consequent: PropLogicFormula): PropLogicFormula =
  PropLogicFormula(
    formulaType: PropFormulaType.impliesProp,
    antecedent: antecedent,
    consequent: consequent
  )

proc `==`*(left, right: TruthVaue): bool =
  left.value == right.value

proc `==`*(left, right: PropLogicFormula): bool = 
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

proc generateAtomicProp(id: int): PropLogicFormula = 
  result = PropLogicFormula(
    formulaType: PropFormulaType.atomicProp,
    id: id
  )

proc getAllInterpretations(numberOfFormulae: int): seq[Interpretation] = 
  let 
    numberOfInterpretation = 1 shl numberOfFormulae
  for pattern in 0..<numberOfInterpretation:
    var interpretation = initTable[int, TruthVaue]()
    for id in 0..<numberOfFormulae:
      interpretation[id] = if (pattern and (1 shl id)) > 0: TOP else: BOTTOM
    result.add(interpretation)

proc init*(numberOfFormulae: int): (seq[PropLogicFormula], seq[Interpretation]) =
  let
    formulae = (0..<numberOfFormulae).toSeq.mapIt(it.generateAtomicProp())
    interpretation = numberOfFormulae.getAllInterpretations()
  return (formulae, interpretation)

proc isSat*(formula: PropLogicFormula, interpretation: Interpretation): bool = 
  formula.eval(interpretation) == TOP

proc getModels*(formula: PropLogicFormula, interpretations: seq[Interpretation]): seq[Interpretation] =
  interpretations.filterIt(formula.isSat(it))

proc isTautology*(formula: PropLogicFormula, interpretations: seq[Interpretation]): bool = 
  formula.getModels(interpretations).len == interpretations.len
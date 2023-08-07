import tables
import sequtils
import sets

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
var nextPropId: int = 0

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

proc generateAtomicProp*(): PropLogicFormula = 
  result = PropLogicFormula(
    formulaType: PropFormulaType.atomicProp,
    id: nextPropId
  )
  nextPropId += 1

proc isSat*(formula: PropLogicFormula, interpretation: Interpretation): bool = 
  formula.eval(interpretation) == TOP

proc getAllInterpretations*(propsId: HashSet[int]): seq[Interpretation] = 
  let 
    numberOfFormulae = propsId.len
    numberOfInterpretation = 1 shl numberOfFormulae
    allPropIds = propsId.toSeq
  for pattern in 0..<numberOfInterpretation:
    var interpretation = initTable[int, TruthVaue]()
    for idx in 0..<numberOfFormulae:
      interpretation[allPropIds[idx]] = if (pattern and (1 shl idx)) > 0: TOP else: BOTTOM
    result.add(interpretation)

proc getModels*(formula: PropLogicFormula, interpretations: seq[Interpretation]): seq[Interpretation] =
  interpretations.filterIt(formula.isSat(it))

proc isTautology*(formula: PropLogicFormula, interpretations: seq[Interpretation]): bool = 
  formula.getModels(interpretations).len == interpretations.len
type
  PropLogicFormula* = ref object of RootObj
  AtomicProp* = ref object of PropLogicFormula
    id*: int
  AndFormula* = ref object of PropLogicFormula
    left*, right*: PropLogicFormula
  OrFormula* = ref object of PropLogicFormula
    left*, right*: PropLogicFormula
  NotFormula* = ref object of PropLogicFormula
    formula*: PropLogicFormula
  ImpliesFormula* = ref object of PropLogicFormula
    antecedent*, consequent*: PropLogicFormula
  TruthVaue* = ref object
    value*: bool

proc `&`* (left, right: PropLogicFormula): AndFormula = 
  AndFormula(left: left, right: right)

proc `|`*(left, right: PropLogicFormula): OrFormula = 
  OrFormula(left: left, right: right)

proc `!`*(formula: PropLogicFormula): NotFormula =
  NotFormula(formula: formula)

proc `=>`*(antecedent, consequent: PropLogicFormula): ImpliesFormula =
  ImpliesFormula(antecedent: antecedent, consequent: consequent)
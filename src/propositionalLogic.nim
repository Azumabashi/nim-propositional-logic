type
  PropLogicFormula* = ref object of RootObj
  AtomicProp* = ref object of PropLogicFormula
    id*: int
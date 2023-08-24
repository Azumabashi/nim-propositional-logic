import formulae
import interpretationUtils
import truthValue
import sequtils

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
  for interpretation in interpretations():
    if not formula.isSat(interpretation):
      return false
  return true

proc isContradiction*(formula: PropLogicFormula): bool =
  ## Returns `true` if given the formula contradicts and `false` otherwise.
  ## Be careful of computational complexity.
  formula.getModels().len == 0

proc isContradiction*(theory: seq[PropLogicFormula]): bool =
  ## Returns `true` if the given theory contradicts and `false` otherwise.
  ## Be careful of computational complexity.
  theory.concatWithAnd().getModels().len == 0

proc iff*(left, right: PropLogicFormula): bool =
  ## Returns `true` if `left` and `right` are logical equivalent, i.e. 
  ## both `left => right`  and `right => left` are tautology, and
  ## returns `false` otherwise.
  runnableExamples:
    import propositionalLogic
    let
      p = generateAtomicProp()
      q = generateAtomicProp()
      formula1 = p => q
      formula2 = !p | q
    check formula1 iff formula2
  ((left => right) & (right => left)).isTautology()
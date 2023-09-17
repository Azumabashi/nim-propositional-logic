import constants
import formulae
import deques
import strutils
import algorithm
import tables

proc toReversePolishNotation(formula: string): seq[string] =
  var 
    operatorLevelPairs: seq[(string, int)]
    level = 0
    i = 0
  
  while i < formula.len:
    var token = $(formula[i])
    if token == leftParen:
      level += 1
    elif token == rightParen:
      level -= 1
    elif token.isOperator() or token == "=":
      if token == "=":
        i += 1
        assert formula[i] == '>', "Unknown token: =" & formula[i]
        token = "=>"
      if operatorLevelPairs.len > 0 and operatorLevelPairs[^1][1] > level:
        for operatorLevelPair in operatorLevelPairs.reversed:
          result.add(operatorLevelPair[0])
        operatorLevelPairs = @[]
      operatorLevelPairs.add((token, level))
    else:
      var j = i + 1
      while j < formula.len and not (
        formula[j] == '=' or isOperator(formula[j]) or isParen(formula[j])
      ):
        j += 1
      result.add(formula[i..<j].strip())
      i = j - 1
    i += 1
  
  for operatorLevelPair in operatorLevelPairs.reversed:
    result.add(operatorLevelPair[0])

proc parse*(
  formula: string, 
  nameToAtomicFormulae: Table[string, PropLogicFormula]
): (PropLogicFormula, Table[string, PropLogicFormula]) =
  ## Parse formula expressed as string. 
  ## Returns pair of parsed formula and table which maps atomic proposition's name in `formula` to
  ## atomic propositon expressed as `PropLogicFormula` after parsing.
  ## 
  ## The format of `formula` should be one of `$`, i.e. no parentheses can be omitted.
  ## When atomic propositions are required to get parse result,
  ## if atomic proposition corresponds to name in `formula` exists in `nameToAtomicFormulae`, 
  ## `nameToAtomicFormulae[name]` is used. Othwewise, new atomic propositions are generated.
  ## For more details, see runnable example.
  runnableExamples:
    import propositionalLogic
    import tables
    import sets
    import sequtils

    let
      p = generateAtomicProp()
      q = generateAtomicProp()
      formula = "((!p) => (q | r))"
      nameToAtomicFormulae = {
        "p": p,
        "q": q,
      }.toTable
      (parsedFormula, newNameToAtomicFormulae) = formula.parse()
    
    assert formula == ($parsedFormula)
    ## atomic proposition corresponds to `r` is generated automatically.
    assert newNameToAtomicFormulae.keys().toSeq().toHashSet() == @["p", "q", "r"].toHashSet()
  
  let reversePolishNotation = formula.toReversePolishNotation()
  var 
    deque = initDeque[PropLogicFormula]()
    newNameToAtomicFormulae = nameToAtomicFormulae
  for token in reversePolishNotation:
    if token.isOperator():
      case token
      of andSymbol:
        let
          right = deque.popLast()
          left = deque.popLast()
        deque.addLast(left & right)
      of orSymbol:
        let
          right = deque.popLast()
          left = deque.popLast()
        deque.addLast(left | right)
      of notSymbol:
        let subFormula = deque.popLast()
        deque.addLast(!subFormula)
      of impliesSymbol:
        let
          consequent = deque.popLast()
          antecedent = deque.popLast()
        deque.addLast(antecedent => consequent)
      else:
        assert false, "No procedure for " & token & " exists!"
    elif not token.isParen():
      if not newNameToAtomicFormulae.hasKey(token):
        newNameToAtomicFormulae[token] = generateAtomicProp()
      deque.addLast(newNameToAtomicFormulae[token])
    else:
      assert false, "Unknown token: " & token
  assert deque.len == 1, "Parse result is not single formula: " & $deque
  let parseResult = deque.popLast()
  return (parseResult, newNameToAtomicFormulae)
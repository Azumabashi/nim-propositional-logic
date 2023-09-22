import constants
import formulae
import deques
import strutils
import tables
import sequtils
import math

proc toReversePolishNotation(formula: string): seq[string] =
  var 
    operatorLevelPairs: Deque[(string, int)]
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
      if operatorLevelPairs.len > 0 and operatorLevelPairs.peekLast()[1] > level:
        while operatorLevelPairs.len > 0 and operatorLevelPairs.peekLast()[1] > level:
          result.add(operatorLevelPairs.popLast()[0])
      operatorLevelPairs.addLast((token, level))
    elif token != " ":
      var j = i + 1
      while j < formula.len and not (
        formula[j] == '=' or isOperator(formula[j]) or isParen(formula[j])
      ):
        j += 1
      result.add(formula[i..<j].strip())
      i = j - 1
    i += 1
  
  while operatorLevelPairs.len > 0:
    result.add(operatorLevelPairs.popLast()[0])

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
  ## 
  ## Note that This procedure uses very naive parsing method and does not construct any AST.
  runnableExamples:
    import propositionalLogic
    import tables
    import sets
    import sequtils
    import strutils

    let
      p = generateAtomicProp()
      q = generateAtomicProp()
      formula = "((!p) => (q | r))"
      nameToAtomicFormulae = {
        "p": p,
        "q": q,
      }.toTable
      (parsedFormula, newNameToAtomicFormulae) = formula.parse(nameToAtomicFormulae)
      idToName = newNameToAtomicFormulae.pairs().toSeq().mapIt(($(it[1].getId()), it[0]))
    
    assert formula.replace(" ", "") == ($parsedFormula).multiReplace(idToName)
    ## atomic proposition corresponds to `r` is generated automatically.
    assert newNameToAtomicFormulae.keys().toSeq().toHashSet() == @["p", "q", "r"].toHashSet()
  
  let 
    logicalConnectiveCount = @[andSymbol, orSymbol, notSymbol, impliesSymbol].mapIt(formula.count(it)).sum()
    leftParenCount = formula.count(leftParen)
    rightParenCount = formula.count(rightParen)
  
  # simple syntax check
  assert logicalConnectiveCount == leftParenCount, "number of logical connectives and left parenthesis is different"
  assert logicalConnectiveCount == rightParenCount, "number of logical connectives and right parenthesis is different"
  
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
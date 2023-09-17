import constants
import formulae
import deques
import strutils
import algorithm

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
        assert formula[i] == '>'
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

proc parse*(formula: string): PropLogicFormula =
  let reversePolishNotation = formula.toReversePolishNotation()
  var deque = initDeque[PropLogicFormula]()
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
        assert false  # This cannot be reached!
    elif not token.isParen():
      let id = token.parseInt()
      deque.addLast(generateAtomicPropWithGivenId(id))
    else:
      assert false
  assert deque.len == 1
  result = deque.popLast()
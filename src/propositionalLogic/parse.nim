import constants

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
    elif token.isOperator():
      if token == "=":
        i += 1
        assert formula[i] == '>'
        token = "=>"
      if operatorLevelPairs.len > 0 and operatorLevelPairs[^1][1] > level:
        for operatorLevelPair in operatorLevelPairs:
          result.add(operatorLevelPair[0])
        operatorLevelPairs = @[]
      operatorLevelPairs.add((token, level))
    else:
      var j = 1
      while not isOperator($(formula[i+j])) and not isParen($(formula[i+j])):
        j += 1
      result.add(formula[i..<i+j])
  for operatorLevelPair in operatorLevelPairs:
    result.add(operatorLevelPair[0])
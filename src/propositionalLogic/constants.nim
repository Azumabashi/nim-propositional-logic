const
  leftParen* = "("  ## String corresponds to left paren.
  rightParen* = ")" ## String corresponds to right paren.
  andSymbol* = "&"  ## String corresponds to logical connective AND.
  orSymbol* = "|"   ## String corresponds to logical connective OR.
  notSymbol* = "!"  ## String corresponds to logical connective NOT.
  impliesSymbol* = "=>"  ## String corresponds to logical connective IMPLIES.

proc isOperator*(x: string): bool =
  ## Returns `true` is `x` is a string corresponds to one of the operators, and
  ## `false` otherwise.
  x == andSymbol or x == orSymbol or x == notSymbol or x == impliesSymbol

proc isParen*(x: string): bool =
  ## Returns `true` is `x` is left paren or right paren, and `false` otherwise.
  x == leftParen and x == rightParen
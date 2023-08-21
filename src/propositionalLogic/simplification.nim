import formulae
import interpretationUtils
import evalUtils
import truthValue
import tables

type
  InterpretationType {.pure.} = enum
    top, bot, dontCare
  TopNumberToITypeSeq =  Table[int, seq[seq[InterpretationType]]]

proc `+`(left, right: TopNumberToITypeSeq): TopNumberToITypeSeq =
  result = left
  for count in right.keys():
    if result.hasKey(count):
      for s in right[count]:
        if result[count].contains(s):
          result[count].add(s)
    else:
      result[count] = right[count]

proc formulaToInterpretationTypeSeq(formula: PropLogicFormula): TopNumberToITypeSeq =
  let numberOfAtomicProps = getNumberOfAtomicProps()
  for interpretation in interpretations():
    if formula.isSat(interpretation):
      var 
        interpretationTypeSeq: seq[InterpretationType] = @[]
        numberOfTop = 0
      for id in 1..numberOfAtomicProps:
        if interpretation[id] == TOP:
          interpretationTypeSeq.add(InterpretationType.top)
          numberOfTop += 1
        else:
          interpretationTypeSeq.add(InterpretationType.bot)
      if result.hasKey(numberOfTop):
        result[numberOfTop].add(interpretationTypeSeq)
      else:
        result[numberOfTop] = @[interpretationTypeSeq]

proc hamming(x, y: seq[InterpretationType]): int =
  doAssert x.len == y.len
  for idx in 0..<x.len:
    if x[idx] == y[idx]:
      result += 1

proc merge(xs, ys: seq[seq[InterpretationType]]): TopNumberToITypeSeq =
  for x in xs:
    for y in ys:
      if hamming(x, y) != 1:
        continue
      var 
        newSeq: seq[InterpretationType] = @[]
        topCount = 0
      for idx in 0..<x.len:
        if x[idx] == y[idx]:
          if x[idx] == InterpretationType.top or x[idx] == InterpretationType.bot:
            topCount += 1
          newSeq.add(x[idx])
        else:
          newSeq.add(InterpretationType.dontCare)
      if result.hasKey(topCount):
        result[topCount].add(newSeq)
      else:
        result[topCount] = @[newSeq]
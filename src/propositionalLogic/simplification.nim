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

proc canMerge(x, y: seq[InterpretationType]): bool =
  doAssert x.len == y.len
  var differs = 0
  for idx in 0..<x.len:
    if (x[idx] == InterpretationType.top and y[idx] == InterpretationType.bot) or
       (x[idx] == InterpretationType.bot and y[idx] == InterpretationType.top):
      differs += 1
    elif x[idx] != y[idx]:
      return false
  return differs == 1

proc merge(x, y: seq[InterpretationType]): (int, seq[InterpretationType]) =
  var 
    newSeq: seq[InterpretationType] = @[]
    topCount = 0
  for idx in 0..<x.len:
    if x[idx] == y[idx]:
      if x[idx] == InterpretationType.top:
        topCount += 1
      newSeq.add(x[idx])
    else:
      newSeq.add(InterpretationType.dontCare)
  return (topCount, newSeq)

proc merge(xs, ys: seq[seq[InterpretationType]], topCountInX: int): TopNumberToITypeSeq =
  var used: TopNumberToITypeSeq = initTable[int, seq[seq[InterpretationType]]]()
  for x in xs:
    for y in ys:
      if not canMerge(x, y):
        continue
      let (topCount, newSeq) = merge(x, y)
      if result.hasKey(topCount):
        result[topCount].add(newSeq)
      else:
        result[topCount] = @[newSeq]
import formulae
import interpretationUtils
import evalUtils
import truthValue
import tables
import sequtils
import math

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

proc countTop(xs: seq[InterpretationType]): int = 
  xs.mapIt(if it == InterpretationType.top: 1 else: 0).sum()

proc formulaToInterpretationTypeSeq(formula: PropLogicFormula): TopNumberToITypeSeq =
  let numberOfAtomicProps = getNumberOfAtomicProps()
  for interpretation in interpretations():
    if formula.isSat(interpretation):
      var 
        interpretationTypeSeq: seq[InterpretationType] = @[]
        numberOfTop = 0
      for id in 0..<numberOfAtomicProps:
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

proc merge(xs, ys: seq[seq[InterpretationType]], topCountInX, topCountInY: int): TopNumberToITypeSeq =
  var 
    mergeResult: TopNumberToITypeSeq = initTable[int, seq[seq[InterpretationType]]]()
    isYsUsed = repeat(false, ys.len)
  for x in xs:
    var isXUsed = false
    for yIdx in 0..<ys.len:
      let y = ys[yIdx]
      if not canMerge(x, y):
        continue
      isXUsed = true
      isYsUsed[yIdx] = true
      let (topCount, newSeq) = merge(x, y)
      if mergeResult.hasKey(topCount):
        mergeResult[topCount].add(newSeq)
      else:
        mergeResult[topCount] = @[newSeq]
    if isXUsed:
      continue
    if mergeResult.hasKey(topCountInX):
      mergeResult[topCountInX].add(x)
    else:
      mergeResult[topCountInX] = @[x]
  for idx in 0..<isYsUsed.len:
    if isYsUsed[idx]:
      continue
    if mergeResult.hasKey(topCountInY):
      mergeResult[topCountInY].add(ys[idx])
    else:
      mergeResult[topCountInY] = @[ys[idx]]
  return mergeResult

proc merge(before: TopNumberToITypeSeq): TopNumberToITypeSeq =
  let keys = before.keys().toSeq
  result = initTable[int, seq[seq[InterpretationType]]]()
  for idx1 in keys:
    let idx2 = idx1 + 1
    if not keys.contains(idx2):
      continue
    result = result + merge(before[idx1], before[idx2], idx1, idx2)

proc getTableAfterMerging(init: TopNumberToITypeSeq): TopNumberToITypeSeq =
  result = init
  var mergeResult = merge(init)
  while result != mergeResult:
    result = mergeResult
    mergeResult = merge(mergeResult)

proc flatten(table: TopNumberToITypeSeq): seq[seq[InterpretationType]] =
  for key in table.keys():
    for content in table[key]:
      result.add(content)

proc simplification(formula: PropLogicFormula): PropLogicFormula =
  let 
    itSeq = formula.formulaToInterpretationTypeSeq()
    candidates = itSeq.getTableAfterMerging().flatten()
    befores = itSeq.flatten()
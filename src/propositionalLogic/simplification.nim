import formulae
import interpretationUtils
import evalUtils
import truthValue
import tables
import sequtils
import math
import algorithm

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
  var pool: seq[seq[InterpretationType]] = @[]
  for key in table.keys():
    for content in table[key]:
      pool.add(content)
  result = (0..<pool.len)
    .toSeq()
    .sorted(proc(x, y: int): int = cmp(pool[x].countTop(), pool[y].countTop()))
    .mapIt(pool[it])

proc isMatch(raw, pattern: seq[InterpretationType]): bool = 
  for i in 0..<raw.len:
    if pattern[i] == InterpretationType.dontCare:
      continue
    elif pattern[i] == raw[i]:
      continue
    else:
      return false
  return true

proc getMatchTable(befores, candidates: seq[seq[InterpretationType]]): Table[int, seq[int]] =
  for beforeIdx in 0..<befores.len:
    for candidateIdx in 0..<candidates.len:
      if not isMatch(befores[beforeIdx], candidates[candidateIdx]):
        continue
      if result.hasKey(beforeIdx):
        result[beforeIdx].add(candidateIdx)
      else:
        result[beforeIdx] = @[candidateIdx]

proc simplification(formula: PropLogicFormula): PropLogicFormula =
  let 
    itSeq = formula.formulaToInterpretationTypeSeq()
    candidates = itSeq.getTableAfterMerging().flatten()
    befores = itSeq.flatten()
  var
    matchTable = getMatchTable(befores, candidates)
  let
    matchTableKey = matchTable.keys().toSeq()
  var simplificated: seq[int] = @[]
  for beforeIdx in matchTableKey:
    if matchTable[beforeIdx].len == 1:
      simplificated.add(matchTable[beforeIdx][0])
      matchTable.del(beforeIdx)
  for key in matchTable.keys():
    for alreadyTaken in simplificated:
      if matchTable[key].contains(alreadyTaken):
        matchTable[key].del(alreadyTaken)
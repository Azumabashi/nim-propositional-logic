## This file provides procedure to make the logical formula simpler.
## Note that the result may not be the simplest form.
## Be careful of computational complexity.

import formulae
import interpretationUtils
import evalUtils
import truthValue
import tables
import sequtils
import math
import algorithm
import sets

type
  InterpretationType {.pure.} = enum
    top, bot, dontCare
  TopNumberToITypeSeq =  Table[int, seq[seq[InterpretationType]]]

proc `+`(left, right: TopNumberToITypeSeq): TopNumberToITypeSeq =
  result = left
  for count in right.keys():
    if result.hasKey(count):
      for s in right[count]:
        if not result[count].contains(s):
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

proc merge(xs, ys: seq[seq[InterpretationType]], topCountInX, topCountInY: int): (TopNumberToITypeSeq, HashSet[int], HashSet[int]) =
  var 
    mergeResult: TopNumberToITypeSeq = initTable[int, seq[seq[InterpretationType]]]()
    isYsUsed = repeat(false, ys.len)
    notUsedXsIdx = initHashSet[int]()
    notUsedYsIdx = initHashSet[int]()
  for xIdx in 0..<xs.len:
    let x = xs[xIdx]
    var isXUsed = false
    for yIdx in 0..<ys.len:
      let y = ys[yIdx]
      if not canMerge(x, y):
        continue
      isXUsed = true
      isYsUsed[yIdx] = true
      let (topCount, newSeq) = merge(x, y)
      if mergeResult.hasKey(topCount) and not mergeResult[topCount].contains(newSeq):
        mergeResult[topCount].add(newSeq)
      else:
        mergeResult[topCount] = @[newSeq]
    if isXUsed:
      continue
    notUsedXsIdx.incl(xIdx)
  for idx in 0..<isYsUsed.len:
    if isYsUsed[idx]:
      continue
    notUsedYsIdx.incl(idx)
  return (mergeResult, notUsedXsIdx, notUsedYsIdx)

proc merge(before: TopNumberToITypeSeq): TopNumberToITypeSeq =
  let keys = before.keys().toSeq
  var notUsedIdx = initTable[int, HashSet[int]]()
  for key in keys:
    notUsedIdx[key] = (0..<before[key].len).toSeq.toHashSet()
  result = initTable[int, seq[seq[InterpretationType]]]()
  for idx1 in 0..<keys.len:
    let 
      topCount1 = keys[idx1]
      topCount2 = topCount1 + 1
      idx2 = keys.find(topCount2)
    if idx2 == -1:
      continue
    let (mergeResult, notUsed1, notUsed2) = merge(before[topCount1], before[topCount2], topCount1, topCount2)
    result = result + mergeResult
    notUsedIdx[idx1] = notUsed1 * notUsedIdx[idx1]
    notUsedIdx[idx2] = notUsedIdx[idx2] * notUsed2
  for idx in 0..<keys.len:
    let key = keys[idx]
    for notUsed in notUsedIdx[key].toSeq():
      if result.hasKey(key):
        result[key].add(before[key][notUsed])
      else:
        result[key] = @[before[key][notUsed]]

proc compare(left, right: TopNumberToITypeSeq): bool = 
  if left.keys.toSeq.toHashSet != right.keys.toSeq.toHashSet:
    return false
  let keys = left.keys.toSeq
  return keys.allIt(left[it].toHashSet == right[it].toHashSet)

proc getTableAfterMerging(init: TopNumberToITypeSeq): TopNumberToITypeSeq =
  result = init
  var mergeResult = merge(init)
  while not compare(result, mergeResult):
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

proc simplification*(formula: PropLogicFormula): PropLogicFormula =
  ## Returns simpler and equivalent formula to given formula.
  ## This procedure is based on Quine–McCluskey algorithm (just based on).
  ## **Note that this procedure does not always return the simplest formula.**
  ## Be careful of computational complexity.
  let 
    itSeq = formula.formulaToInterpretationTypeSeq()
  let
    simplicatedResults = itSeq.getTableAfterMerging().flatten()
  var formulae: seq[PropLogicFormula] = @[]
  for simplicatedResult in simplicatedResults:
    var propositions: seq[PropLogicFormula] = @[]
    for idx in 0..<simplicatedResult.len:
      case simplicatedResult[idx]
      of InterpretationType.top:
        propositions.add(generateAtomicPropWithGivenId(idx))
      of InterpretationType.bot:
        propositions.add(!generateAtomicPropWithGivenId(idx))
      else:
        discard
    formulae.add(propositions.foldl(a & b))
  formulae.foldl(a | b)
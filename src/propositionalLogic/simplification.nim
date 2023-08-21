import formulae
import interpretationUtils
import evalUtils
import truthValue
import tables

type
  InterpretationType {.pure.} = enum
    top, bot, dontCare

proc formulaToInterpretationTypeSeq(formula: PropLogicFormula): Table[int, seq[seq[InterpretationType]]] =
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
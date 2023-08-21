import formulae
import interpretationUtils
import evalUtils
import truthValue
import tables

type
  InterpretationType {.pure.} = enum
    top, bot, dontCare

proc formulaToInterpretationTypeSeq(formula: PropLogicFormula): seq[seq[InterpretationType]] =
  let numberOfAtomicProps = getNumberOfAtomicProps()
  for interpretation in interpretations():
    if formula.isSat(interpretation):
      var interpretationTypeSeq: seq[InterpretationType] = @[]
      for id in 1..numberOfAtomicProps:
        if interpretation[id] == TOP:
          interpretationTypeSeq.add(InterpretationType.top)
        else:
          interpretationTypeSeq.add(InterpretationType.bot)
      result.add(interpretationTypeSeq)
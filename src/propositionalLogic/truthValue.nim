type
  TruthValue* = ref object
    ## Object corresponds to truth value.
    ## Two truth values "True" and "False" are distinguished by the field of this object.
    value*: bool
let
  TOP* = TruthValue(value: true)
    ## Logical constatnt represents `true`.
  BOTTOM* = TruthValue(value: false)
    ## Logical constant represents `false`.

proc `==`*(left, right: TruthValue): bool =
  ## Compare two truth values.
  left.value == right.value

proc `and`*(left, right: TruthValue): TruthValue =
  ## Returns `TOP` if both `left` and `right` are `TOP` and `BOTTOM` otherwise.
  TruthValue(
    value: left.value and right.value
  )

proc `or`*(left, right: TruthValue): TruthValue = 
  ## Returns `TOP` if `left` or `right` are `TOP` and `BOTTOM` otherwise.
  TruthValue(
    value: left.value or right.value
  )

proc `not`*(val: TruthValue): TruthValue =
  ## Returns `BOTTOM` if `val` is `TOP` and `TOP` otherwise.
  if val == TOP: BOTTOM else: TOP
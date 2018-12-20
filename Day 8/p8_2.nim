import strutils
import algorithm
import math

var fields: seq[int]

for field in "data".readFile().split():
  fields.add(field.parseInt())
fields.reverse    # Reverse values to process them more easily.

proc getValue(fields: var seq[int]): int =

  let childCount = fields.pop()
  let metadataCount = fields.pop()

  # Process children.
  var values = newSeqOfCap[int](childCount)
  for _ in 1..childCount:
    values.add(fields.getValue())

  # Read metadata.
  var metadata = newSeqOfCap[int](metadataCount)
  for _ in 1..metadataCount:
    metadata.add(fields.pop())

  # Process metadata.
  if childCount == 0:
    # No child: simply add metadata.
    result = sum(metadata)
  else:
    # Add values from children according to metadata.
    for idx in metadata:
      if idx > 0 and idx <= values.len:
        inc result, values[idx - 1]

echo fields.getValue()

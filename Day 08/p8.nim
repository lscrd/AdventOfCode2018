import std/[algorithm, math, strutils]

var fields: seq[int]

# Read fields from the data file.
for field in readFile("p8.data").split():
  fields.add field.parseInt()
fields.reverse()    # Reverse values to process them more easily.

let fieldsRef = fields  # Copy for part 2.


### Part 1 ###

proc getMetadataSum(fields: var seq[int]): int =
  ## Compute the metadata sum.
  let childCount = fields.pop()
  let metadataCount = fields.pop()
  # Add metadata from children.
  for _ in 1..childCount:
    inc result, fields.getMetadataSum()
  # Add own metadata.
  for _ in 1..metadataCount:
    inc result, fields.pop()

echo "Part 1: ", fields.getMetadataSum()


### Part 2 ###

proc getValue(fields: var seq[int]): int =
  ## Return the value associated to the fields.
  let childCount = fields.pop()
  let metadataCount = fields.pop()
  # Process children.
  var values = newSeqOfCap[int](childCount)
  for _ in 1..childCount:
    values.add fields.getValue()
  # Read metadata.
  var metadata = newSeqOfCap[int](metadataCount)
  for _ in 1..metadataCount:
    metadata.add fields.pop()
  # Process metadata.
  if childCount == 0:
    # No child: simply add metadata.
    result = sum(metadata)
  else:
    # Add values from children according to metadata.
    for idx in metadata:
      if idx > 0 and idx <= values.len:
        inc result, values[idx - 1]

fields = fieldsRef
echo "Part 2: ", fields.getValue()

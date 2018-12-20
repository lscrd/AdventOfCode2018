import strutils
import algorithm
import math

var fields: seq[int]

for field in "data".readFile().split():
  fields.add(field.parseInt())
fields.reverse    # Reverse values to process them more easily.

proc getMetadataSum(fields: var seq[int]): int =

  let childCount = fields.pop()
  let metadataCount = fields.pop()
  # Add metadata from children.
  for _ in 1..childCount:
    inc result, fields.getMetadataSum()
  # Add own metadata.
  for _ in 1..metadataCount:
    inc result, fields.pop()

echo fields.getMetadataSum()

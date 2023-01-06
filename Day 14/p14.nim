import std/algorithm

type Score = range[0..9]

var
  scores: seq[Score] = @[Score 3, 7]    # List of scores.
  idx1 = 0                              # Recipe index for first elf.
  idx2 = 1                              # Recipe index for second elf.

# Decompose a number into digits.
proc digits(n: int): seq[Score] =
  var n = n
  while true:
    result.add (n mod 10)
    n = n div 10
    if n == 0: break
  result.reverse()

proc createRecipes(scores: var seq[Score]; idx1, idx2: var int): int =
  ## Create one or two new recipes. Return the number of recipes created.
  let prevLen = scores.len
  let score1 = scores[idx1]
  let score2 = scores[idx2]
  scores.add digits(score1 + score2)
  idx1 = (idx1 + score1 + 1) mod scores.len
  idx2 = (idx2 + score2 + 1) mod scores.len
  result = scores.len - prevLen

# Puzzle value.
const N = 580_741


### Part 1 ###

# Create recipes.
while scores.len < N + 10:
  discard createRecipes(scores, idx1, idx2)

# Build the result string
var result: string
for score in scores[^10..^1]:
  result.addInt score

echo "Part 1: ", result


### Part 2 ###

const Target = digits(N)

proc firstMatch(scores, target: openArray[Score]): bool =
  ## Check if the first new recipe matches the target when
  ## two recipes have been created.
  for i in 1..target.len:
    if scores[^(i + 1)] != target[^i]:
      return false
  result = true

proc lastMatch(scors, target: openArray[Score]): bool =
  ## Check if the last created recipe matches the target.
  for i in 1..target.len:
    if scores[^i] != target[^i]:
      return false
  result = true

# Make sure we have enough scores to start comparisons.
var n: int
while scores.len <= Target.len:
  n = createRecipes(scores, idx1, idx2)

# Build the recipes until the target is found.
var index: int
while true:
  if n == 2 and firstMatch(scores, Target):
    # First score of two matches.
    index = scores.len - Target.len - 1
    break
  if lastMatch(scores, Target):
    # Last score matches.
    index = scores.len - Target.len
    break
  n = createRecipes(scores, idx1, idx2)

echo "Part 2: ", index

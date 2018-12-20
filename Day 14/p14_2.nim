import algorithm

type Score = range[0..9]

var
  scores: seq[Score] = @[Score 3, 7]    # List os scores.
  idx1 = 0                              # Recipe index for first elf.
  idx2 = 1                              # Recipe index for second elf.

# Decompose a number into digits.
proc digits(n: int): seq[Score] =
  var n = n
  while true:
    result.add(n mod 10)
    n = n div 10
    if n == 0:
      break
  result.reverse

# Create one or two new recipes.
# Return the number of recipes created.
proc createRecipes(scores: var seq[Score]; idx1, idx2: var int): int =
  let prevlen = scores.len
  let score1 = scores[idx1]
  let score2 = scores[idx2]
  scores.add(digits(score1 + score2))
  idx1 = (idx1 + score1 + 1) mod scores.len
  idx2 = (idx2 + score2 + 1) mod scores.len
  result = scores.len - prevlen

# Compare two open arrays. We use this to avoid the copy done when using a slice.
proc equals(a, b: openArray[Score]): bool = a == b

let N = 580_741
let target = digits(N)
# Make sure we have enough scores to start comparisons.
var n: int
while scores.len <= target.len:
  n = createRecipes(scores, idx1, idx2)
# Build the recipes until the target is found.
while true:
  if n == 2 and equals(scores.toOpenarray(scores.high - target.len, scores.high - 1), target):
    # Check for the first score added.
    echo scores.high - target.len
    break
  if equals(scores.toOpenarray(scores.high - target.high, scores.high), target):
    # Check for the last score added.
    echo scores.high - target.high
    break
  n = createRecipes(scores, idx1, idx2)

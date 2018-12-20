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
proc createRecipes(scores: var seq[Score]; idx1, idx2: var int) =
  let score1 = scores[idx1]
  let score2 = scores[idx2]
  scores.add(digits(score1 + score2))
  idx1 = (idx1 + score1 + 1) mod scores.len
  idx2 = (idx2 + score2 + 1) mod scores.len

# Create recipes.
let N = 580_741
while scores.len < N + 10:
  createRecipes(scores, idx1, idx2)

# Build the result string
var result: string
for score in scores[^10..^1]:
  result.add($score)

echo result

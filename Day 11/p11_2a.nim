# Optimized version using a sum array to compute levels incrementally.
# This array is sized to 300x300 but the actual data area decreases
# when size increases. We could have used a sequence and resized it
# but didn't want to mix 0-based indexes with 1-based indexes.
# Using a sequence for both arrays was another possible option, likely
# a little slower. This version is indeed quite fast.

const SN = 8772

var
  grid: array[1..300, array[1..300, int]]
  levels: array[1..300, array[1..300, int]]

# Fill grid full power levels.
for x in 1..300:
  let rackId = x + 10
  for y in 1..300:
    grid[y][x] = (rackId * y + SN) * rackId mod 1000 div 100 - 5

# Initialize levels for size 1.
var bestPowerLevel = -6
var best: tuple[x, y, size: int]
for x in 1..300:
  for y in 1..300:
    let level = grid[y][x]
    levels[y][x] = level
    if level > bestPowerLevel:
      bestPowerLevel = level
      best = (x, y, 1)

# Find the block with higher power level.
for size in 2..300:
  let delta = size - 1
  for x in 1..(300 - delta):
    for y in 1..(300 - delta):
      var level =  levels[y][x] + grid[y + delta][x + delta]
      for x1 in x..<(x + delta):
        inc level, grid[y + delta][x1]
      for y1 in y..<(y + delta):
        inc level, grid[y1][x + delta]
      levels[y][x] = level
      if level > bestPowerLevel:
        bestPowerLevel = level
        best = (x, y, size)

echo best, ' ', bestPowerLevel

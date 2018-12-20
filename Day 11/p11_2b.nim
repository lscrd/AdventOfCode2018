# First version which computes levels from start for each size, so it is slow.

const SN = 8772

var grid: array[1..300, array[1..300, int]]

# Fill grid full powerlevel.
for x in 1..300:
  let rackId = x + 10
  for y in 1..300:
    grid[y][x] = (rackId * y + SN) * rackId mod 1000 div 100 - 5

# Find the block with higher power level.
var bestPowerLevel = -6
var best: tuple[x, y, size: int]
for size in 1..300:
  for x in 1..(300 + 1 - size):
    for y in 1..(300 + 1 - size):
      var powerLevel = 0
      for dx in 0..(size - 1):
        for dy in 0..(size - 1):
          inc powerLevel, grid[y + dy][x + dx]
      if powerLevel > bestPowerLevel:
        bestPowerLevel = powerLevel
        best = (x, y, size)

echo best, ' ', bestPowerLevel

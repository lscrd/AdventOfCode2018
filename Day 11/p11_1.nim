# Note that first indice is "y" as we manage an array or rows.

const SN = 8772

var grid: array[1..300, array[1..300, int]]

# Fill grid full power level.
for x in 1..300:
  let rackId = x + 10
  for y in 1..300:
    grid[y][x] = (rackId * y + SN) * rackId mod 1000 div 100 - 5

# Find the 3x3 block with higher power level.
var bestPowerLevel = -6
var bestxy: tuple[x, y: int]
for x in 1..298:
  for y in 1..298:
    var powerLevel = 0
    for dx in 0..2:
      for dy in 0..2:
        inc powerLevel, grid[y + dy][x + dx]
    if powerLevel > bestPowerLevel:
      bestPowerLevel = powerLevel
      bestxy = (x, y)

echo bestxy, ' ', bestPowerLevel

import strutils
import algorithm
import pegs

const
  MAX = 100000
  MIN = -100000

type
  Star = tuple[y, x, vy, vx: int]
  Area = tuple[minx, maxx, miny, maxy: int]

var stars: seq[Star]
var area: Area = (MAX, MIN, MAX, MIN)

# Simulate one step. Return the area.
proc doOneStep(stars: var seq[Star]): Area =
  result = (MAX, MIN, MAX, MIN)
  for star in stars.mitems:
    inc star.x, star.vx
    inc star.y, star.vy
    if star.x < result.minx: result.minx = star.x
    if star.x > result.maxx: result.maxx = star.x
    if star.y < result.miny: result.miny = star.y
    if star.y > result.maxy: result.maxy = star.y

# Display the stars.
proc display(stars: seq[Star]) =

  # Compute the minimal value for "x".
  var minx = MAX
  for star in stars:
    if star.x < minx: minx = star.x

  # Sort stars (as "y" coordinates are the first in the tuple, standard sorting works).
  let stars = stars.sorted(system.cmp)

  var curry = stars[0].y  # Current y position.
  let startx = minx - 1   # Sarting x position.
  var currx = startx      # Current x position.
  var line: string        # Current line to draw.
  # Draw stars.
  for star in stars:
    if star.y > curry:
      # New line.
      echo line
      for _ in 1..(star.y - curry - 1): echo ""    # Add empty lines if needed.
      currx = startx
      curry = star.y
      line.setLen(0)
    # Draw the star.
    if star.x != currx:   # Be sure that there is not another star at the same place.
      for _ in 1..(star.x - currx - 1): line.add(' ')
      line.add('#')
      currx = star.x
  # Display last line.
  echo line

# Parse the star file.
let intExpr = peg"'-'?\d+"
for line in "data".lines:
  let matches = line.findAll(intExpr)
  let x = matches[0].parseInt()
  let y = matches[1].parseInt()
  if x < area.minx: area.minx = x
  if x > area.maxx: area.maxx = x
  if y < area.miny: area.miny = y
  if y > area.maxy: area.maxy = y
  stars.add((y, x, matches[3].parseInt(), matches[2].parseInt()))

# Simulate until we find the position with the minimal area.
var decreasing = false
while true:
  let prevstars = stars
  let prevarea = area
  area = stars.doOneStep()
  if area.maxx - area.minx <= prevarea.maxx - prevarea.minx and
     area.maxy - area.miny <= prevarea.maxy - prevarea.miny:
    decreasing = true
  elif decreasing:
    # Minimum has been encountered.
    prevstars.display()
    break

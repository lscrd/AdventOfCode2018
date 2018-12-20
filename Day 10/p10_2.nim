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
var time = 0
while true:
  inc time
  let prevarea = area
  area = stars.doOneStep()
  if area.maxx - area.minx <= prevarea.maxx - prevarea.minx and
     area.maxy - area.miny <= prevarea.maxy - prevarea.miny:
    decreasing = true
  elif decreasing:
    echo time - 1
    break

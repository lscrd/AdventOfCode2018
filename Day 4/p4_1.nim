import algorithm
import strutils
import tables
import times

type
  Action = enum Sleeps, WakesUp
  Item = tuple[id: int, dt: DateTime, act: Action]

var history: seq[Item]

var sleeptime = initCountTable[int]()

proc extractId(line: string): int =
  var idx = 25
  while true:
    inc idx
    let c = line[idx]
    if c == ' ': break
    result = 10 * result + ord(c) - ord('0')

var lines: seq[string]
for line in "puzzle4".lines:
  lines.add(line)
lines.sort(system.cmp)

# Build the history.
var id: int
for line in lines:
  let dt = parse(line[1..16], "yyyy-MM-dd hh:mm")
  let action = line[19..23]
  if action == "Guard":
    id = line.extractId()
  elif action == "falls":
    history.add((id, dt, Sleeps))
  elif action == "wakes":
    history.add((id, dt, WakesUp))
  else:
    echo "Error"

# Find the total sleep time for each guard and keep the best id.
var startmin: int
for item in history:
  if item.act == Sleeps:
    startmin = item.dt.minute
  else:
    sleeptime.inc(item.id, item.dt.minute - startmin)
let bestid = sleeptime.largest.key

# Compute the sleep time per minute.
var minutes: array[60, int]
for item in history:
  if item.id != bestid: continue
  if item.act == Sleeps:
    startmin = item.dt.minute
  else:
    for m in startmin..<item.dt.minute:
      inc minutes[m]

# Find the best minute.
var maxtime = 0
var bestmin: int
for m, t in minutes:
  if t > maxtime:
    maxtime = t
    bestmin = m

echo bestid * bestmin

import algorithm
import strutils
import tables
import times

type
  Action = enum Sleeps, WakesUp
  Item = tuple[id: int, dt: DateTime, act: Action]

var
  history: seq[Item]
  sleeptime = initTable[int, seq[int]]()

proc extractId(line: string): int =
  var idx = 25
  while true:
    inc idx
    let c = line[idx]
    if c == ' ': break
    result = 10 * result + ord(c) - ord('0')

var lines: seq[string]
for line in "data".lines:
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

# Find the total sleep time for each guard and each minute.
var startmin: int
for item in history:
  if item.act == Sleeps:
    startmin = item.dt.minute
    if item.id notin sleeptime:
      sleeptime[item.id] = newSeq[int](60)
  else:
    for m in startmin..<item.dt.minute:
      inc sleeptime[item.id][m]

# Find the best minute and the corresponding id.
var bestid: int
var maxtime = 0
var bestmin: int
for id, minutes in sleeptime.pairs:
  for m, t in minutes:
    if t > maxtime:
      maxtime = t
      bestid = id
      bestmin = m

echo bestid * bestmin

import std/[algorithm, sequtils, tables, times]

type
  Action {.pure.} = enum Sleeps, WakesUp
  Item = tuple[id: int, dt: DateTime, action: Action]
  History = seq[Item]

proc extractId(line: string): int =
  ## Extract the ID from a line.
  var idx = 25
  while true:
    inc idx
    let c = line[idx]
    if c == ' ': break
    result = 10 * result + ord(c) - ord('0')

proc buildHistory(lines: seq[string]): History =
  ## Build the histiry from the list of action lines.
  var id: int
  for line in lines:
    let dt = parse(line[1..16], "yyyy-MM-dd hh:mm")
    let action = line[19..23]
    case action
    of "Guard": id = line.extractId()
    of "falls": result.add (id, dt, Sleeps)
    of "wakes": result.add (id, dt, WakesUp)

# Read the lines, sort them and build the history.
let lines = sorted(toSeq(lines("p4.data")))
let history = lines.buildHistory()


### Part 1 ###

proc findBestId(history: History): int =
  # Find the total sleep time for each guard and keep the best ID.
  var sleepTime: CountTable[int]
  var startMin: int   # Starting minute.
  for item in history:
    case item.action
    of Sleeps: startMin = item.dt.minute
    of WakesUp: sleepTime.inc(item.id, item.dt.minute - startMin)
  result = sleeptime.largest.key

proc findBestMinute(history: History; bestId: int): int =
  ## Return the best minute for the guard with best ID.
  var sleepTimes: array[60, int]   # Sleep time for each minute.
  var startMin: int    # Starting minute.
  for item in history:
    if item.id != bestid: continue
    case item.action
    of Sleeps:
      startMin = item.dt.minute
    of WakesUp:
      for m in startMin..<item.dt.minute:
        inc sleepTimes[m]
  result = maxIndex(sleepTimes)

var bestId = history.findBestId()
var bestMin = history.findBestMinute(bestId)

echo "Part 1: ", bestId * bestMin


### Part 2 ###

proc findBestIdAndMinute(history: History): (int, int) =

  # Total sleep time for each guard and each minute.
  var sleepTimes: CountTable[(int, int)]
  var startMin: int     # Starting minute.
  for item in history:
    case item.action
    of Sleeps:
      startmin = item.dt.minute
    of WakesUp:
      for m in startmin..<item.dt.minute:
        sleepTimes.inc((item.id, m))

  # Find the best minute and the associated ID.
  result = sleepTimes.largest().key

(bestId, bestMin) = history.findBestIdAndMinute()

echo "Part 2: ", bestId * bestMin

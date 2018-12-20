import strutils
import tables

var
  state: string                       # Current state.
  start: int                          # Position of pot 0.
  rules = initTable[string, char]()   # Rules to apply.

state.add("....")   # Add some empty pots at beginning.
start = 4

# Parse the file.
for line in "data".lines:
  if line.startsWith("initial"):
    state.add(line[line.find({'.', '#'})..^1])
  elif line.len > 0:
    let parts = line.split(" => ")
    rules[parts[0]] = parts[1][0]

state.add("....")   # Add some empty pots at end.

# Compute next state. Return the state and the new starting position.
proc nextGen(state: string, start: int): tuple[state: string, start: int] =
  result.state = "...."     # Add some empty pots at beginning.
  result.start = start + 2  # Adjust starting position.
  var empty = true
  for idx in 0..(state.high - 4):
    let next = rules.getOrDefault(state[idx..(idx + 4)], '.')
    if empty:
      # No plant found until now.
      if next == '.':
        # Ignore this pot.
        dec result.start
        continue
      empty = false   # We have encountered the first non empty pot.
    # Update the state.
    result.state.add(next)
  # Adjust last pots.
  let n = 4 - (result.state.high - result.state.rfind('#'))
  if n > 0:
    # Add some empty pots at end.
    result.state.add(repeat('.', n))
  else:
    # Too much empty pots at end.
    result.state.setLen(result.state.len - n)

# Run the simulation.
for _ in 1..20:
  (state, start) = nextgen(state, start)

# Compute the result.
var result = 0
for idx, value in state:
  if value == '#':
    inc result, idx - start
echo result

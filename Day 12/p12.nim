import std/[strutils, tables]

var
  state: string                # Current state.
  start: int                   # Position of pot 0.
  rules: Table[string, char]   # Rules to apply.

state.add("....")   # Add some empty pots at beginning.
start = 4

proc nextGen(state: string; start: int): tuple[state: string, start: int] =
  ## Compute next state. Return the state and the new starting position.
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
    result.state.add next
  # Adjust last pots.
  let n = 4 - (result.state.high - result.state.rfind('#'))
  if n > 0:
    # Add some empty pots at end.
    result.state.add(repeat('.', n))
  else:
    # Too much empty pots at end.
    result.state.setLen(result.state.len - n)

proc value(state: string; start: int): int =
  ## Compute the sum of the numbers of pots which contain a plant.
  for idx, value in state:
    if value == '#':
      inc result, idx - start

# Parse the file.
for line in lines("p12.data"):
  if line.startsWith("initial"):
    state.add line[line.find({'.', '#'})..^1]
  elif line.len > 0:
    let parts = line.split(" => ")
    rules[parts[0]] = parts[1][0]

state.add("....")   # Add some empty pots at end.


### Part 1 ###

# Run the simulation.
for _ in 1..20:
  (state, start) = nextgen(state, start)

echo "Part 1: ", state.value(start)


### Part 2 ###

# Run the simulation until the state doesn't change (except
# a shift of one position to the right).
var n = 0
while true:
  inc n
  let oldstate = state
  (state, start) = nextgen(state, start)
  if state == oldstate:
    break

# For 50_000_000_000 generations, we have only to update the starting position.
dec start, int 50_000_000_000 - n

echo "Part 2: ", state.value(start)

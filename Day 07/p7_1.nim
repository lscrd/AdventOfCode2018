import strscans
import strutils
import tables

var previousSteps = initTable[char, set[char]]()
var stepsToDo: set[char]

# Build the table of steps.
for line in "data".lines:
  var s1, s2: string
  discard line.scanf("Step $w must be finished before step $w can begin.", s1, s2)
  let step1 = s1[0]
  let step2 = s2[0]
  previousSteps.mgetOrPut(step2, {}).incl(step1)
  stepsToDo.incl(step1)
  stepsToDo.incl(step2)

# Add missing keys in the table.
for step in stepsToDo:
  if step notin previousSteps:
    previousSteps[step] = {}

var stepList: seq[char]
while stepsToDo.card > 0:
  var candidates: seq[char]
  for step, steps in previousSteps.pairs():
    if card(steps * stepsToDo) == 0:
      # All needed steps have been completed.
      candidates.add(step)
  let chosenStep = min(candidates)
  stepList.add(chosenStep)
  stepsToDo.excl(chosenStep)
  previousSteps.del(chosenStep)

echo stepList.join

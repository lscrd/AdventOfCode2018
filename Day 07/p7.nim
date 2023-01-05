import std/[strscans, strutils, tables]

type
  StepSet = set[char]
  PreviousSteps = Table[char, StepSet]

proc readData(filename: string; previous: var PreviousSteps; toDo: var StepSet) =
  # Build the table and the set of steps to complete.
  for line in lines(filename):
    var s1, s2: string
    discard line.scanf("Step $w must be finished before step $w can begin.", s1, s2)
    let step1 = s1[0]
    let step2 = s2[0]
    previous.mgetOrPut(step2, {}).incl(step1)
    toDo.incl step1
    toDo.incl step2
  # Add missing keys in the table.
  for step in toDo:
    if step notin previous:
      previous[step] = {}


### Part 1 ###

var previousSteps: PreviousSteps
var stepsToDo: StepSet
readData("p7.data", previousSteps, stepsToDo)

var stepList: seq[char]
while card(stepsToDo) > 0:
  var candidates: seq[char]
  for step, steps in previousSteps.pairs():
    if card(steps * stepsToDo) == 0:
      # All needed steps have been completed.
      candidates.add step
  let chosenStep = min(candidates)
  stepList.add chosenStep
  stepsToDo.excl chosenStep
  previousSteps.del chosenStep

echo "Part 1: ", stepList.join


### Part 2 ###

var stepsToAssign: StepSet
previousSteps.clear()
readData("p7.data", previousSteps, stepsToAssign)

const
  BaseTime = 60
  Workers = 5
  NoStep = ' '

# Worker description.
type Worker = object
  num: int          # Worker number.
  step: char        # Current step in progress ("NoStep" if none).
  remaining: int    # Remaining time.

var
  workers: array[Workers, Worker]   # List of workers.
  stepsCompleted: StepSet           # Set of completed steps.
  time: int                         # Current time.
  stepCount = previousSteps.len     # Number of steps to complete.

# Duration of a step.
proc stepDuration(step: char): int {.inline.} = BaseTime + ord(step) - ord('A') + 1

proc nextStep(): char =
  ## Return next step to start ("NoStep" is none can be started).
  var candidates: seq[char]
  for step, steps in previousSteps.pairs():
    if step in stepsToAssign and steps <= stepsCompleted:
      # All needed steps have been completed.
      candidates.add step
  result = if candidates.len > 0: min(candidates) else: NoStep

proc assignSteps() =
  # Assign steps to workers.
  for worker in workers.mitems:
    let step = nextStep()
    if step == NoStep: return   # No available step.
    if worker.step == NoStep:
      # Worker is available.
      if previousSteps[step] <= stepsCompleted:
        # Next step is possible. Assign it to worker.
        worker.step = step
        worker.remaining = step.stepDuration()
        stepsToAssign.excl step

proc checkSteps() =
  ## Check if steps are completed.
  for worker in workers.mitems:
    if worker.step != NoStep:
      # Worker is working.
      dec worker.remaining
      if worker.remaining == 0:
        # Step is terminated.
        stepsCompleted.incl worker.step
        worker.step = NoStep

var num = 0
for worker in workers.mitems:
  inc num
  worker.num = num
  worker.step = NoStep

time = -1
while card(stepsCompleted) < stepCount:
  inc time
  checkSteps()
  assignSteps()

echo "Part 2: ", time

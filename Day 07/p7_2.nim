import strscans
import strutils
import tables
import algorithm
import strformat

####################################################################################################
# Build the table of steps.

var previousSteps = initTable[char, set[char]]()
var stepsToAssign: set[char]

for line in "data".lines:
  var s1, s2: string
  discard line.scanf("Step $w must be finished before step $w can begin.", s1, s2)
  let step1 = s1[0]
  let step2 = s2[0]
  previousSteps.mgetOrPut(step2, {}).incl(step1)
  stepsToAssign.incl(step1)
  stepsToAssign.incl(step2)

# Add missing keys in the table.
for step in stepsToAssign:
  if step notin previousSteps:
    previousSteps[step] = {}


####################################################################################################
# Process steps.

const
  BASETIME = 60
  WORKERS = 5
  NOSTEP = ' '

# Worker description.
type Worker = object
  num: int          # Worker number.
  step: char        # Current step in progress.
  remaining: int    # Remaining time.

var
  workers: array[WORKERS, Worker]   # List of workers.
  stepsCompleted: set[char]         # Set of completed steps.
  time: int                         # Current time.
  stepCount = previousSteps.len     # Number of steps to complete.

# Duration of a step.
proc stepDuration(step: char): int {.inline.} = BASETIME + ord(step) - ord('A') + 1

# Find next step to start.
proc nextStep(): char =
  var candidates: seq[char]
  for step, steps in previousSteps.pairs():
    if step in stepsToAssign and steps <= stepsCompleted:
      # All needed steps have been completed.
      candidates.add(step)
  result = if candidates.len > 0: min(candidates) else: NOSTEP

# Assign steps to workers.
proc assignSteps() =
  for worker in workers.mitems:
    let step = nextStep()
    if step == NOSTEP: return   # No available step.
    if worker.step == NOSTEP:
      # Worker is available.
      if previousSteps[step] <= stepsCompleted:
        # Next step is possible. Assign it to worker.
        worker.step = step
        worker.remaining = step.stepDuration()
        stepsToAssign.excl(step)
        echo fmt"{time:3}: step {worker.step} started by worker {worker.num}"

# Check if steps are completed.
proc checkSteps() =
  for worker in workers.mitems:
    if worker.step != NOSTEP:
      # Worker is working.
      dec worker.remaining
      if worker.remaining == 0:
        # Step is terminated.
        echo fmt"{time:3}: step {worker.step} completed by worker {worker.num}"
        stepsCompleted.incl(worker.step)
        worker.step = NOSTEP

var num = 0
for worker in workers.mitems:
  inc num
  worker.num = num
  worker.step = NOSTEP

time = -1
while stepsCompleted.card < stepCount:
  inc time
  checkSteps()
  assignSteps()

echo time

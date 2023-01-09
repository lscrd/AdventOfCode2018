import std/[strscans, strutils]

type
  Registers = array[4, int]
  Opcode = enum Addr, Addi, Mulr, Muli, Banr, Bani, Borr, Bori
                Setr, Seti, Gtir, Gtri, Gtrr, Eqir, Eqri, Eqrr
  Operands = array[1..3, int]
  Instruction = tuple[opcode: Opcode; ops: Operands]

  Sample = object
    before, after: Registers
    codeval: int
    ops: Operands

proc execute(regs: Registers, instruction: Instruction): Registers =
  ## Execute an instruction.

  let opcode = instruction.opcode
  let op1 = instruction.ops[1]
  let op2 = instruction.ops[2]
  let op3 = instruction.ops[3]
  result = regs

  result[op3] = case opcode
    of Addr: regs[op1] + regs[op2]
    of Addi: regs[op1] + op2
    of Mulr: regs[op1] * regs[op2]
    of Muli: regs[op1] * op2
    of Banr: regs[op1] and regs[op2]
    of Bani: regs[op1] and op2
    of Borr: regs[op1] or regs[op2]
    of Bori: regs[op1] or op2
    of Setr: regs[op1]
    of Seti: op1
    of Gtir: ord(op1 > regs[op2])
    of Gtri: ord(regs[op1] > op2)
    of Gtrr: ord(regs[op1] > regs[op2])
    of Eqir: ord(op1 == regs[op2])
    of Eqri: ord(regs[op1] == op2)
    of Eqrr: ord(regs[op1] == regs[op2])

## Store the input lines in a sequence.
let data = readFile("p16.data").splitLines()

# Process samples.
var samples: seq[Sample]
var bef, aft: Registers
var cval: int
var ops: Operands
var idx = 0           # Line index in "data".
var emptyLines = 0    # Number of consecutive empty lines.
while emptyLines < 3:
  if data[idx].scanf("Before:$s[$i, $i, $i, $i]", bef[0], bef[1], bef[2], bef[3]):
    assert data[idx + 1].scanf("$i $i $i $i", cval, ops[1], ops[2], ops[3])
    assert data[idx + 2].scanf("After:$s[$i, $i, $i, $i]", aft[0], aft[1], aft[2], aft[3], aft[3])
    samples.add Sample(before: bef, after: aft, codeval: cval, ops: ops)
    emptyLines = 0
    inc idx, 3
  else:
    inc emptyLines
    inc idx


### Part 1 ###

proc matchCount(sample: Sample): int =
  ## Compute the count of matching opcodes.
  var instr: Instruction
  instr.ops = sample.ops
  for opcode in Opcode.low..Opcode.high:
    instr.opcode = opcode
    if sample.before.execute(instr) == sample.after:
      inc result

var count = 0
for sample in samples:
  if sample.matchCount() >= 3:
    inc count

echo "Part 1: ", count


### Part 2 ###

import std/setutils

type
  Candidates = array[16, set[Opcode]]   # Set of candidate opcodes for each code value.
  OpCodes = array[16, OpCode]           # Maps code value value to OpCode value.

# Extract the first value from a set.
proc first[T](s: set[T]): T =
  for item in s.items:
    return item

proc update(candidates: var Candidates; sample: Sample) =
  ## Update the candidates.
  var poss: set[Opcode]             # Matching opcodes.
  var instr: Instruction
  instr.ops = sample.ops
  for opcode in Opcode.low..Opcode.high:
    instr.opcode = opcode
    if sample.before.execute(instr) == sample.after:
      poss.incl opcode
  candidates[sample.codeval] = candidates[sample.codeval] * poss

proc getOpCodes(candidates: var Candidates): OpCodes =
  ## Build the array of OpCodes.
  var allAssigned = false
  while not allAssigned:
    allAssigned = true
    for codeval in 0..15:
      let codeset = candidates[codeval]
      if card(codeset) == 1:
        # We can assign the value to the opcode.
        let opcode = codeset.first()
        result[codeval] = opcode
        # Remove the opcode from possibilities for other values.
        for item in candidates.mitems:
          item.excl opcode
      elif card(codeset) != 0:
        # There is still at least a value to assign.
        allAssigned = false


# Initialize the candidates.
var candidates: Candidates
for item in candidates.mitems:
  item = Opcode.fullSet
for sample in samples:
  candidates.update(sample)

# Find opcode values.
let opcodes = candidates.getOpCodes()

# Run the test program.
var regs: Registers
var instr: Instruction
while idx <= data.high:
  discard data[idx].scanf("$i $i $i $i", cval, instr.ops[1], instr.ops[2], instr.ops[3])
  instr.opcode = opcodes[cval]
  regs = regs.execute(instr)
  inc idx

echo "Part 2: ", regs[0]

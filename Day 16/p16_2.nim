import strutils
import sequtils
import pegs

type
  Registers = array[4, int]
  Opcode = enum Addr, Addi, Mulr, Muli, Banr, Bani, Borr, Bori
                Setr, Seti, Gtir, Gtri, Gtrr, Eqir, Eqri, Eqrr
  Operands = array[1..3, int]
  Instruction = tuple[opcode: Opcode; ops: Operands]

# Set of candidate opcodes for each code value.
type Candidates = array[16, set[Opcode]]
var candidates: Candidates
for item in candidates.mitems:
  item = {Opcode.low..Opcode.high}

# Execute an instruction.
proc execute(regs: Registers, instruction: Instruction): Registers =
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

# Update the candidates.
proc update(candidates: var Candidates; before, after: Registers; codeval: int; ops: Operands) =
  var poss: set[Opcode]             # Matching opcodes.
  var instr: Instruction
  instr.ops = ops
  for opcode in Opcode.low..Opcode.high:
    instr.opcode = opcode
    if before.execute(instr) == after:
      poss.incl(opcode)
  candidates[codeval] = candidates[codeval] * poss

# Extract the first value from a set.
proc first[T](s: set[T]): T =
  for item in s.items:
    return item

let data = "data".readFile().split('\n')
let number = peg"\d+"

# Process samples.
var before, after: Registers
var ops: Operands
var codeval: int
var idx = 0           # Line index in "data".
var emptyLines = 0    # Number of consecutive empty lines.
while emptyLines < 3:
  if data[idx].startsWith("Before"):
    for i, val in data[idx].findAll(number).map(parseInt):
      before[i] = val
    for i, val in data[idx + 1].findAll(number).map(parseInt):
      if i == 0:
        codeval = val
      else:
        ops[i] = val
    for i, val in data[idx + 2].findAll(number).map(parseInt):
      after[i] = val
    candidates.update(before, after, codeval, ops)
    inc idx, 3
    emptyLines = 0
  elif data[idx].len == 0:
    inc idx
    inc emptyLines

# Find opcode values.
var opcodes: array[16, Opcode]    # Mapping from opcode value to opcode enum.
var allAssigned = false
while not allAssigned:
  allAssigned = true
  for codeval in 0..15:
    let codeset = candidates[codeval]
    if codeset.card == 1:
      # We can assign the value to the opcode.
      let opcode = codeset.first()
      opcodes[codeval] = opcode
      # Remove the opcode from possibilities for other values.
      for item in candidates.mitems:
        item.excl(opcode)
    elif codeset.card != 0:
      # There is still at least a value to assign.
      allAssigned = false

# Run the test program.
var regs: Registers
var instr: Instruction
while idx <= data.high:
  for i, val in data[idx].findAll(number).map(parseInt):
    if i == 0:
      instr.opcode = opcodes[val]
    else:
      instr.ops[i] = val
  regs = regs.execute(instr)
  inc idx

echo regs[0]

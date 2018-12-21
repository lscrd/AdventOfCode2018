import strutils
import strscans
import math

type
  Registers = array[6, int]
  Opcode = enum Addr, Addi, Mulr, Muli, Banr, Bani, Borr, Bori
                Setr, Seti, Gtir, Gtri, Gtrr, Eqir, Eqri, Eqrr
  Operands = array[1..3, int]
  Instruction = tuple[opcode: Opcode; ops: Operands]

# Execute an instruction.
proc execute(regs: var Registers, instruction: Instruction) =
  let opcode = instruction.opcode
  let op1 = instruction.ops[1]
  let op2 = instruction.ops[2]
  let op3 = instruction.ops[3]

  regs[op3] = case opcode
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

# Read the program.
var pcreg = -1
var program: seq[Instruction]
var code: string
var ops: array[1..3, int]
for line in "data".lines:
  if line.scanf("$+ $i $i $i", code, ops[1], ops[2], ops[3]):
    program.add((parseEnum[Opcode](code), ops))
  elif not line.scanf("#ip $i", pcreg):
    quit "Error while parsing data."

######################################################
# Part 1.
# The program exits when R4 = R0, so find the first value of R4
# just before the comparison (antepenultimate instruction).

var pc = 0
var regs: Registers = [0, 0, 0, 0, 0, 0]
var firstR4: int
while true:
  if pc == program.high - 2:
    firstR4 = regs[4]
    break
  regs[pcreg] = pc
  regs.execute(program[pc])
  pc = regs[pcreg] + 1

echo "Part 1: ", firstR4

######################################################
# Part 2.
# It’s obvious that values in R4 follows a cycle. So, we have
# to find the first value already encountered and to return
# the previous one.

const optimizedVersion = true

when not optimizedVersion:
  # The following code is the normal way to do that, but is is slow.
  pc = 0
  regs = [0, 0, 0, 0, 0, 0]
  var values: seq[int]
  while true:
    if pc == program.high - 2:
      if regs[4] in values:
        break
      values.add(regs[4])
    regs[pcreg] = pc
    regs.execute(program[pc])
    pc = regs[pcreg] + 1

  echo "Part 2: ", values[^1]

else:
  # Here is an optimized version which is not interpreted.

  # Compute next value of R4.
  proc nextValue(r4: int): int =
    var r4 = r4
    var r1: int
    while true:
      r1 = r4 or 0x10000
      r4 = 16031208
      while r1 != 0:
        r4 = (r4 + (r1 and 0xff)) and 0xffffff
        r4 = (r4 * 65899) and 0xffffff
        r1 = r1 shr 8
      return r4

  var values: seq[int]
  var r4 = 0
  while r4 notin values:
    values.add(r4)
    r4 = nextValue(r4)
  echo "Part 2: ", values[^1]

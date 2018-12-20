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

var pc = 0
var regs: Registers
while true:
  regs[pcreg] = pc
  regs.execute(program[pc])
  pc = regs[pcreg] + 1
  if pc > program.high:
    break
echo "Part 1: ", regs[0]

######################################################
# Part 2.

# Analyzing the code shows that it computes the sum of all divisors of
# the number contained in R4, but with a very inefficient algorithm even
# in native code.
# With R0 = 1, the number contained in R4 is much greater that with R0 = 0,
# so we use our own and reasonably efficient algorithm to find the result.

# Find the number contained in R4.
pc = 0
regs = [1, 0, 0, 0, 0, 0]
while true:
  regs[pcreg] = pc
  regs.execute(program[pc])
  pc = regs[pcreg] + 1
  if pc == 2:
    # Start of external loop and end of initialization. Stop here.
    break

# Compute the sum of all divisors of "n".
var n = regs[4]               # The value to find and sum the divisors.
var p = 0                     # Candidate divisors.
var m = sqrt(n.toFloat).int   # Upper limit for "p".
var sol = 0                   # The sum of divisors.
while p < m:
  inc p
  if n mod p == 0:
    let q = n div p
    inc sol, p
    if q != p:
      inc sol, q
echo "Part 2: ", sol


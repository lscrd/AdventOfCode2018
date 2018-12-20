import strutils

let data = "data".readFile()

proc react(data: string): int =
    var res = "\0"    # Add a char at beginning to simplify the algorithm.
    for c in data:
      if c != res[^1] and c.toLowerAscii == res[^1].toLowerAscii:
          res.setLen(res.high)  # Pop one char.
      else:
        res.add(c)              # Add char to result.
    result = res.len - 1

##########################################
# Part 1.

echo "Part 1: ", data.react()

##########################################
# Part 2.

# Find the unit types.
var units: set[char]
for c in data:
  units.incl(c.toLowerAscii)

# Try each type.
var minlength = data.len
for unit in units:
  let s = data.multiReplace(($unit, ""), ($(unit.toUpperAscii), ""))
  let length = s.react()
  if length < minlength:
    minlength = length

echo "Part 2: ", minlength

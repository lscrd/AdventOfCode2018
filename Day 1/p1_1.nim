import strutils

var freq = 0
for line in "puzzle1".lines:
  freq += line.parseInt()

echo freq

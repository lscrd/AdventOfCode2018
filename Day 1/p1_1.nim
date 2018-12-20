import strutils

var freq = 0
for line in "data".lines:
  freq += line.parseInt()

echo freq

import tables

var count2, count3 = 0

for line in "data".lines:
  let counts = line.toCountTable()
  var has2, has3 = false
  for count in counts.values:
    if count == 2:
      has2 = true
      if has3: break
    elif count == 3:
      has3 = true
      if has2: break
  if has2:
    inc count2
  if has3:
    inc count3

echo count2 * count3

import algorithm

type
  # Parts of a path.
  Part = enum vpath, hpath, curve1, curve2, intersection, empty
  # Directions. "error" is used to detect inconsistencies.
  Direction = enum right, left, up, down, error
  # Position of a cart ("y" first to make comparison easier).
  Position = tuple[y, x: int]
  # Next move of a cart.
  Move = enum turnLeft, goStraight, turnRight
  # Cart description.
  Cart = object
    num: int        # Number (index in list of carts).
    pos: Position   # Current position.
    dir: Direction  # Current direction.
    nextMove: Move  # Next move at intersection.
    removed: bool   # True if the cart has been removed.

  Tracks = seq[seq[Part]]     # Description of the tracks as a matrix of parts.
  Crash = object              # Description of a possible crash.
    case hasCrashed: bool
    of false:
      discard             # No crash.
    of true:
      pos: Position       # Position of the crash.
      cart1, cart2: int   # Numbers of crashed carts.

var
  tracks: Tracks      # Tracks built from map.
  carts: seq[Cart]    # List of carts.

const
  # Mapping (Direction, Move) to Direction.
  directions1: array[Direction, array[Move, Direction]] =
    [[up, right, down],
     [down, left, up],
     [left, up, right],
     [right, down, left],
     [error, error, error]]
  # Mapping (Direction, Part) to Direction.
  directions2: array[Direction, array[Part, Direction]] =
    [[error, right, up, down, error, error],
     [error, left, down, up, error, error],
     [up, error, right, left, error, error],
     [down, error, left, right, error, error],
     [error, error, error, error, error, error]]

for line in "data".lines:
  tracks.add(@[])
  for c in line:
    case c
    of '|':
      tracks[^1].add(vpath)
    of '-':
      tracks[^1].add(hpath)
    of '/':
      tracks[^1].add(curve1)
    of '\\':
      tracks[^1].add(curve2)
    of '+':
      tracks[^1].add(intersection)
    of ' ':
      tracks[^1].add(empty)
    of '^':
      tracks[^1].add(vpath)
      carts.add(Cart(num: carts.len, pos: (tracks.high, tracks[^1].high), dir: up))
    of 'v':
      tracks[^1].add(vpath)
      carts.add(Cart(num: carts.len, pos: (tracks.high, tracks[^1].high), dir: down))
    of '>':
      tracks[^1].add(hpath)
      carts.add(Cart(num: carts.len, pos: (tracks.high, tracks[^1].high), dir: right))
    of '<':
      tracks[^1].add(hpath)
      carts.add(Cart(num: carts.len, pos: (tracks.high, tracks[^1].high), dir: left))
    else: echo "error when parsing"

# Compute next direction for a cart.
proc nextDirection(tracks: Tracks, cart: var Cart): Direction =
  var part = tracks[cart.pos.y][cart.pos.x]
  if part == intersection:
    result = directions1[cart.dir][cart.nextMove]
    cart.nextMove = if cart.nextMove == turnRight: turnLeft else: succ(cart.nextMove)
  else:
    result = directions2[cart.dir][part]
    if result == error:
      echo "error for next direction"
      echo cart, " ", part
      quit()

# Move a cart.
proc moveCart(tracks: Tracks, cart: var Cart): Crash =
  # Compute new coordinates.
  case cart.dir
  of right: inc cart.pos.x
  of left: dec cart.pos.x
  of up: dec cart.pos.y
  of down: inc cart.pos.y
  else: discard
  # Compute new direction.
  cart.dir = tracks.nextDirection(cart)
  # Check for crash.
  for othercart in carts:
    if othercart.removed: continue
    if othercart.num != cart.num and othercart.pos == cart.pos:
      return Crash(hasCrashed: true, pos: cart.pos, cart1: cart.num, cart2: othercart.num)
  result = Crash(hasCrashed: false)

# Compare two carts to find the one to move first.
proc compareCarts(cart1, cart2: Cart): int = cmp(cart1.pos, cart2.pos)

# Process a tick.
proc doTick(tracks: Tracks, carts: var seq[Cart]): int =
  let cartlist = carts.sorted(compareCarts)
  for cart in cartlist:
    if cart.removed: continue
    let crash = tracks.moveCart(carts[cart.num])
    if crash.hasCrashed:
      carts[crash.cart1].removed = true
      carts[crash.cart2].removed = true
      inc result, 2

# Do ticks until only a cart remains.
var count = carts.len
while true:
  dec count, tracks.doTick(carts)
  if count == 1:
    for cart in carts:
      if not cart.removed:
        echo cart.pos.x, ',', cart.pos.y
    break


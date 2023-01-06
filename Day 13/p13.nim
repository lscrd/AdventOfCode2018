import std/algorithm

type

  # Parts of a path.
  Part {.pure.} = enum VPath, HPath, Curve1, Curve2, Intersection, Empty
  # Directions. "error" is used to detect inconsistencies.
  Direction {.pure} = enum Right, Left, Up, Down, Error
  # Position of a cart ("y" first to make comparison easier).
  Position = tuple[y, x: int]
  # Next move of a cart.
  Move {.pure.} = enum TurnLeft, GoStraight, TurnRight

  # Cart description.
  Cart = object
    num: int        # Number (index in list of carts).
    pos: Position   # Current position.
    dir: Direction  # Current direction.
    nextMove: Move  # Next move at intersection.
    removed: bool   # True if the cart has been removed (for part 2).

  # Description of the tracks as a matrix of parts.
  Tracks = seq[seq[Part]]

  # Description of a possible crash.
  Crash = object
    case hasCrashed: bool
    of false:
      discard             # No crash.
    of true:
      pos: Position       # Position of the crash.
      cart1, cart2: int   # Crashed carts numbers (for part 2).

var
  tracks: Tracks      # Tracks built from map.
  carts: seq[Cart]    # List of carts.

const

  # Mapping (Direction, Move) to Direction.
  Directions1: array[Direction, array[Move, Direction]] =
    [[Up, Right, Down],
     [Down, Left, Up],
     [Left, Up, Right],
     [Right, Down, Left],
     [Error, Error, Error]]

  # Mapping (Direction, Part) to Direction.
  Directions2: array[Direction, array[Part, Direction]] =
    [[Error, Right, Up, Down, Error, Error],
     [Error, Left, Down, Up, Error, Error],
     [Up, Error, Right, Left, Error, Error],
     [Down, Error, Left, Right, Error, Error],
     [Error, Error, Error, Error, Error, Error]]

proc nextDirection(tracks: Tracks; cart: var Cart): Direction =
  ## Compute next direction for a cart.
  var part = tracks[cart.pos.y][cart.pos.x]
  if part == Intersection:
    result = Directions1[cart.dir][cart.nextMove]
    cart.nextMove = if cart.nextMove == TurnRight: TurnLeft else: succ(cart.nextMove)
  else:
    result = Directions2[cart.dir][part]
    if result == Error:
      echo "error for next direction"
      echo cart, " ", part
      quit()

proc compareCarts(cart1, cart2: Cart): int =
  ## Compare two carts to find the one to move first.
  cmp(cart1.pos, cart2.pos)

proc moveCart(tracks: Tracks; cart: var Cart): Crash =
  ## Move a cart.

  # Compute new coordinates.
  case cart.dir
  of Right: inc cart.pos.x
  of Left: dec cart.pos.x
  of Up: dec cart.pos.y
  of Down: inc cart.pos.y
  else: discard
  # Compute new direction.
  cart.dir = tracks.nextDirection(cart)
  # Check for crash.
  for othercart in carts:
    if othercart.removed: continue
    if othercart.num != cart.num and othercart.pos == cart.pos:
      return Crash(hasCrashed: true, pos: cart.pos, cart1: cart.num, cart2: othercart.num)
  result = Crash(hasCrashed: false)

# Parse the map.
for line in lines("p13.data"):
  tracks.add(@[])
  for c in line:
    case c
    of '|':
      tracks[^1].add VPath
    of '-':
      tracks[^1].add HPath
    of '/':
      tracks[^1].add Curve1
    of '\\':
      tracks[^1].add Curve2
    of '+':
      tracks[^1].add Intersection
    of ' ':
      tracks[^1].add Empty
    of '^':
      tracks[^1].add VPath
      carts.add(Cart(num: carts.len, pos: (tracks.high, tracks[^1].high), dir: Up))
    of 'v':
      tracks[^1].add VPath
      carts.add(Cart(num: carts.len, pos: (tracks.high, tracks[^1].high), dir: Down))
    of '>':
      tracks[^1].add HPath
      carts.add(Cart(num: carts.len, pos: (tracks.high, tracks[^1].high), dir: Right))
    of '<':
      tracks[^1].add HPath
      carts.add(Cart(num: carts.len, pos: (tracks.high, tracks[^1].high), dir: Left))
    else: echo "error when parsing"


### Part 1 ###

proc doTick1(tracks: Tracks; carts: var seq[Cart]): Crash =
  ## Process a tick. Return a Crash object.
  let cartlist = sorted(carts, compareCarts)
  for cart in cartlist:
    result = tracks.moveCart(carts[cart.num])
    if result.hasCrashed:
      return

# Do ticks until a crash occurs.
var crash: Crash
while not crash.hasCrashed:
  crash = tracks.doTick1(carts)

echo "Part 1: ", crash.pos.x, ',', crash.pos.y


### Part 2 ###

proc doTick2(tracks: Tracks; carts: var seq[Cart]): int =
  ## Process a tick with possibility to remove carts.
  ## Return the number of carts removed.
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
while count != 1:
  dec count, tracks.doTick2(carts)

# Find position of the last cart.
var lastCartPos: Position
for cart in carts:
  if not cart.removed:
    lastCartPos = cart.pos
    break

echo "Part 2: ", lastCartPos.x, ',', lastCartPos.y

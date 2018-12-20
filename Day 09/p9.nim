import lists

const
  PLAYERS = 441

var
  ring = initDoublyLinkedRing[int]()
  scores: array[PLAYERS, int]

proc addMarble(ring: var DoublyLinkedRing[int], marble: int) =
  ring.head = ring.head.next.next
  ring.prepend(marble)

proc removedMarble(ring: var DoublyLinkedRing[int]): int =
  var node = ring.head
  for _ in 1..7:
    node = node.prev
  result = node.value
  ring.head = node.next
  ring.remove(node)

proc run(ring: var DoublyLinkedRing, scores: var openarray[int], rounds: int) =

  # Add first marble.
  ring.append(0)

  # Process other marbles.
  var player = 0
  for marble in 1..<rounds:
    inc player
    if player == PLAYERS: player = 0
    if marble mod 23 != 0:
      ring.addMarble(marble)
    else:
      inc scores[player], marble + ring.removedMarble()


################################################
# Part 1.

run(ring, scores, 71_032)
echo "Part 1: ", max(scores)


################################################
# Part 2.

run(ring, scores, 7_103_200)
echo "Part 2: ", max(scores)

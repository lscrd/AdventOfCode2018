import std/lists

const
  Players = 441
  Rounds = 71_032

var
  ring: DoublyLinkedRing[int]
  scores: array[Players, int]

proc addMarble(ring: var DoublyLinkedRing[int]; marble: int) =
  ## Add a marble in the ring.
  ring.head = ring.head.next.next
  ring.prepend(marble)

proc removedMarble(ring: var DoublyLinkedRing[int]): int =
  ## Remove a marble from the ring and return its number.
  var node = ring.head
  for _ in 1..7:
    node = node.prev
  result = node.value
  ring.head = node.next
  ring.remove(node)

proc run(ring: var DoublyLinkedRing; scores: var openarray[int]; rounds: int) =
  ## Run the game for the given number of rounds.

  # Add first marble.
  ring.append(0)

  # Process other marbles.
  var player = 0
  for marble in 1..<rounds:
    inc player
    if player == Players: player = 0
    if marble mod 23 != 0:
      ring.addMarble(marble)
    else:
      inc scores[player], marble + ring.removedMarble()


### Part 1 ###

run(ring, scores, Rounds)
echo "Part 1: ", max(scores)


# Part 2.

run(ring, scores, Rounds * 100)
echo "Part 2: ", max(scores)

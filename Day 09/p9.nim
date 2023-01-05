import std/lists

const
  Players = 441
  Rounds = 71_032

type Scores = array[Players, int]

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

proc runGame(rounds: int; scores: var Scores) =
  ## Run the game for the given number of rounds and return the scores.

  var ring: DoublyLinkedRing[int]
  ring.append(0)
  scores.reset()

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
var scores: Scores
runGame(Rounds, scores)
echo "Part 1: ", max(scores)


# Part 2.
runGame(Rounds * 100, scores)
echo "Part 2: ", max(scores)

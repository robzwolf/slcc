# Avoiding Out of Bounds

## The Plan
Currently your players ignore where they are moving to and can either walk into water, or move into the same position
that another player is already occupying, with the result that you lose players.  This step of the tutorial will add
some logic to prevent these situations from happening.

## Code Updates
### Track Next Positions
You need a list of the positions that your players will occupy on the next turn so that you can avoid collisions, add
it as a local variable in the `makeMoves` method and then pass it through to each method call:

```
List<Position> nextPositions = new ArrayList<>();
```

and replace:

```
moves.addAll(doExplore(gameState));
```

with:

```
moves.addAll(doExplore(gameState, nextPositions));
```

and also:

```
private List<Move> doExplore(final GameState gameState) {
```

with:

```
private List<Move> doExplore(final GameState gameState, final List<Position> nextPositions) {
```

### Check For Out of Bounds
The `GameState` object passed to the `initialise` and `makeMoves` methods contains a range of useful information about
the state of the map on a given turn, for example which visible positions are water, or out of bounds, and also a
map-related utility class `Map`.  This will be passed through to the relevant methods to avoid keeping a reference to
what is essentially a single use object.

First you need to check where a player would end up if it moved in a given direction, so add a `canMove` method which
makes use of a utility method `map.getNeighbour(position, direction)` to get the next position (taking account of the
way that the map wraps at the top/bottom and left/right) and then checks whether that position will already be occupied
or if it is out of bounds.

```
private boolean canMove(final GameState gameState, final List<Position> nextPositions, final Player player, final Direction direction) {
    Set<Position> outOfBounds = gameState.getOutOfBoundsPositions();
    Position newPosition = gameState.getMap().getNeighbour(player.getPosition(), direction);
    if (!nextPositions.contains(newPosition)
        && !outOfBounds.contains(newPosition)) {
        nextPositions.add(newPosition);
        return true;
    } else {
        return false;
    }
}
```

Now you're ready to make use of these methods, so replace the following line in the `doExplore` method:

```
.map(player -> new MoveImpl(player.getId(), Direction.NORTH))
```

with:

```
.map(player -> doMove(gameState, nextPositions, player))
```

The current approach will be to make a player move randomly, you'll do that in the `doMove` method which encapsulates
the movement logic for a player:

```
private Move doMove(final GameState gameState, final List<Position> nextPositions, final Player player) {
    List<Direction> directions = new ArrayList<>(Arrays.asList(Direction.values()));
    Direction direction;
    do {
        direction = directions.remove(ThreadLocalRandom.current().nextInt(directions.size()));
    } while (!directions.isEmpty() && !canMove(gameState, nextPositions, player, direction));
    return new MoveImpl(player.getId(), direction);
}
```

### Testing
Now that your players don't eliminate each other or drown you're ready to send your upgraded Bot into battle, so
run another game.

Windows command prompt:

```batch
gradlew run -P mainClass=<your_bot_class_fully_qualified_name>
```

Unix shell:

```sh
./gradlew run -P mainClass=<your_bot_class_fully_qualified_name>
```

This game should now last much longer, and might even end with the `TURN_LIMIT_REACHED` instead of `LONE_SURVIVOR` end
condition; if so, congratulations on making it to the end of a game! But look at all those collectable items that keep
appearing while your players just mill about around the spawn point.  The [next step](3-gathering-collectables.md) will
be to start picking up the collectables and spawning more players.

## Extra Credit
### Random Directions
Looking at the `doMove` method can you spot the flaw?  For instance, it might be possible, now that you have
more players in the game, that there isn't an empty space available for a player to move to. What will happen in this
situation, and how might you correct it?

### Other Players
It's possible, now that your players are moving further from the spawn point and living longer, that you'll come across
players belonging to other Bots.  What happens if you try to issue moves for a player that does not belong to your bot?

Being disqualified for issuing moves to the wrong players is not going to win you any games so you should update the
stream of players to filter out any that do not belong to your bot:

```
moves.addAll(gameState.getPlayers().stream()
        .filter(player -> isMyPlayer(player))
        .map(player -> doMove(gameState, nextPositions, player))
        .collect(Collectors.toList());
```

```
private boolean isMyPlayer(final Player player) {
    return player.getOwner().equals(getId());
}
```

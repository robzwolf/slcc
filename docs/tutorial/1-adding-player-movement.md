# Adding Player Movement

## The Plan
Move your players off the spawn point so that they do not eliminate players spawned in the following turns.

## Code Updates

### Implementing Move
The first requirement is an implementation of the `Move` interface so that your orders can be returned to the game
engine, the bare minimum is given below.

```
public class MoveImpl implements Move {
    private UUID playerId;
    private Direction direction;
    public MoveImpl(UUID playerId, Direction direction) {
        this.playerId = playerId;
        this.direction = direction;
    }
    @Override
    public UUID getPlayer() {
        return playerId;
    }
    @Override
    public Direction getDirection() {
        return direction;
    }
}
```

As mentioned in the `README`, this should either be an inner class within the file containing your bot, or placed in a
separate package, e.g. `com.contestantbots.util`.

### Issuing Orders
The next step is to put `MoveImpl` to good use, so replace the return statement in the `makeMoves` method:

```
return new ArrayList<>();
```

with:

```
List<Move> moves = new ArrayList<>();

moves.addAll(doExplore(gameState));

return moves;
```

And then you need to implement the `doExplore` method, to start with your players will just move `NORTH` to avoid being
eliminated by any newly spawned player.

```
private List<Move> doExplore(final GameState gameState) {
    List<Move> exploreMoves = new ArrayList<>();

    exploreMoves.addAll(gameState.getPlayers().stream()
            .map(player -> new MoveImpl(player.getId(), Direction.NORTH))
            .collect(Collectors.toList());
    
    System.out.println(exploreMoves.size() + " players exploring");
    return exploreMoves;
}
```

### Testing
Now you're ready to send your upgraded Bot into battle, so run another game.

Windows command prompt:

```batch
gradlew run -P mainClass=<your_bot_class_fully_qualified_name>
```

Unix shell:

```sh
./gradlew run -P mainClass=<your_bot_class_fully_qualified_name>
```

The game should now have lasted 21 phases, but still end with the `LONE_SURVIVOR` end condition as all your players
march in a neat line directly northwards and straight into the nearby water!

So the [next step](2-avoiding-out-of-bounds.md) will be to ensure that your players do not play follow the leader to a
watery end!  While you're checking where your players are going, let's also add some logic so that they avoid colliding
with each other.

# Destroying Enemy Spawn Points

## The Plan
In the same way that you're growing your army by gathering collectables and spawning new players so are your enemies, so
let's put a stop to that by removing the source of their new players.

## Code Updates
### Track Spawnpoint Positions
The `GameState` only includes information on the items that your players can see, which means that if you spot an enemy
spawn point you need to store the position so your Bot doesn't 'forget' where it is if the player moves away from the
the immediate vicinity of the spawn point or is killed.  This is state that you need to track across the duration of a
game so add an instance variable to track the positions:

```
private Set<Position> enemySpawnPointPositions = new HashSet<>();
```

Now you need to update the set at the start of each turn, soo add the following method:

```
private void updateEnemySpawnPointLocations(final GameState gameState) {
    enemySpawnPointPositions.addAll(gameState.getSpawnPoints().stream()
            .filter(spawnPoint -> !spawnPoint.getOwner().equals(getId()))
            .map(spawnPoint -> spawnPoint.getPosition())
            .collect(Collectors.toList()));

    enemySpawnPointPositions.removeAll(gameState.getRemovedSpawnPoints().stream()
            .filter(spawnPoint -> !spawnPoint.getOwner().equals(getId()))
            .map(spawnPoint -> spawnPoint.getPosition())
            .collect(Collectors.toList()));
}
```

Notice how the code removes spawn points that have been reported as destroyed so that your players don't continue to
attack a spawn point that's no longer there!  Next call this at the start of `makeMoves`:

```
updateEnemySpawnPointLocations(gameState);
```

### Attack
Now the important bit, let's assign players to attack the known spawn points:

```
private List<Move> doAttack(final GameState gameState, final Map<Player, Position> assignedPlayerDestinations,
                            final List<Position> nextPositions) {
    List<Move> attackMoves = new ArrayList<>();

    Set<Player> players = gameState.getPlayers().stream()
            .filter(player -> isMyPlayer(player))
            .filter(player -> !assignedPlayerDestinations.containsKey(player.getId()))
            .collect(Collectors.toSet());
    System.out.println(players.size() + " players available to attack");

    List<Route> attackRoutes = generateRoutes(gameState, players, enemySpawnPointPositions);

    Collections.sort(attackRoutes);
    attackMoves.addAll(assignRoutes(gameState, assignedPlayerDestinations, nextPositions, attackRoutes));

    System.out.println(attackMoves.size() + " players attacking");
    return attackMoves;
}
```

And finally add these new moves to the list returned from `makeMoves`:

```
moves.addAll(doAttack(gameState, assignedPlayerDestinations, nextPositions));
```

### Testing
Again you're ready to send your newly aggressive Bot into battle, so run another game as before:

Windows command prompt:

```batch
gradlew run -P mainClass=<your_bot_class_fully_qualified_name>
```

Unix shell:

```sh
./gradlew run -P mainClass=<your_bot_class_fully_qualified_name>
```

Your Bot should now be destroying the enemy spawn point along the way to a `LONE_SURVIVOR` end condition which
concludes the tutorial. But how does your Bot handle more than one enemy, or the more sophisticated Bots? How about
uploading it to the server and taking on Bots written by your competitors?

There are plenty of avenues to explore to improve your Bot, some of which were listed in the [introduction](index.md)
and in the `Extra Credit` sections along the way, but here are a few more possibilities:
- your players are essentially managed as independent agents, other than making sure they don't collide or head to the
same destination. Would it make more sense to have them work together somehow, especially when there are enemy players
in the vicinity?
- the unseen position exploration code has some unexpected side-effects, watch how your players behave during the
middle of a game as they head en-masse to the nearest group of unseen locations.  How easy would it be to avoid this?
- does the logic in the `canMove` method take account of players that don't move on a given turn? What are the
consequences to this and how could it be fixed?
- the `doAttack` method makes use of the default `assignRoutes` algorithm, can you identify a potential flaw with this
approach?  How would you refactor the assignment method to fix this?

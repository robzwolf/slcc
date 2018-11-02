# Exploring the Map

## The Plan
Due to the random directions being assigned on each turn, your players are currently just milling around the spawn point
and need an incentive to move away and explore. This will serve two purposes:
- reduce the congestion around the spawn point reducing the chances that a player cannot move
- increase the visible proportion of the map and therefore increase your chances of spotting collectables

## Code Updates
To achieve this you need to track unseen areas of the map and assign players to explore these locations; this is a
secondary priority to gathering collectables because you want to build up your team of intrepid explorers!

### Preparation
First of all, let's refactor the route generation and assignment code into helper methods as this will avoid duplicated
code once you start adding routes to unseen positions:

```
private List<Route> generateRoutes(final GameState gameState, Set<Player> players, Set<Position> destinations) {
    List<Route> routes = new ArrayList<>();
    for (Position destination : destinations) {
        for (Player player : players) {
            int distance = gameState.getMap().distance(player.getPosition(), destination);
            Route route = new Route(player, destination, distance);
            routes.add(route);
        }
    }
    return routes;
}
```

```
private List<Move> assignRoutes(final GameState gameState, final Map<Player, Position> assignedPlayerDestinations, final List<Position> nextPositions, List<Route> routes) {
    return routes.stream()
            .filter(route -> !assignedPlayerDestinations.containsKey(route.getPlayer())&& !assignedPlayerDestinations.containsValue(route.getDestination()))
            .map(route -> {
                Optional<Direction> direction = gameState.getMap().directionsTowards(route.getPlayer().getPosition(), route.getDestination()).findFirst();
                if (direction.isPresent() && canMove(gameState, nextPositions, route.getPlayer(), direction.get())) {
                    assignedPlayerDestinations.put(route.getPlayer(), route.getDestination());
                    return new MoveImpl(route.getPlayer().getId(), direction.get());
                }
                return null;
            })
            .filter(move -> move != null)
            .collect(Collectors.toList());
}
```

Now you can make use of the new methods in `doCollect`:

```
List<Route> collectableRoutes = generateRoutes(gameState, players, collectablePositions);
```

```
collectMoves.addAll(assignRoutes(gameState, assignedPlayerDestinations, nextPositions, collectableRoutes));
```

### Track Unseen Positions
Add a set to manage the unseen positions in the map; this is state that you need to track throughout the
game, so add it as an instance variable:

```
private Set<Position> unseenPositions = new HashSet<>();
```

And add the following to the `initialise` method as this only needs to be done once:

```
// add all positions to the unseen set
for (int x = 0; x < gameState.getMap().getWidth(); x++) {
    for (int y = 0; y < gameState.getMap().getHeight(); y++) {
        unseenPositions.add(new Position(x, y));
    }
}
```

Before processing your moves, you need to update the set of unseen positions to remove those that are visible on the
current move. The distance that a player can see is not provided as part of the game or map state, so let's _guess_ a
distance and then add methods to calculate the positions that your players can see and remove them from the tracked set:

```
private void updateUnseenLocations(final GameState gameState) {
    // assume players can 'see' a distance of 5 squares
    int visibleDistance = 5;
    final Set<Position> visiblePositions = gameState.getPlayers()
            .stream()
            .filter(player -> isMyPlayer(player))
            .map(player -> player.getPosition())
            .flatMap(playerPosition -> getSurroundingPositions(gameState, playerPosition, visibleDistance))
            .distinct()
            .collect(Collectors.toSet());

    // remove any positions that can be seen
    unseenPositions.removeIf(position -> visiblePositions.contains(position));
}
```

Note above, we've set the initial guess as 5; does this make much difference to the performance of your Bot,
or does it need adjusting?

```
private Stream<Position> getSurroundingPositions(final GameState gameState, final Position position, final int distance) {
    return IntStream.rangeClosed(-distance, distance)
            .mapToObj(x -> IntStream.rangeClosed(-distance, distance)
                    .mapToObj(y -> gameState.getMap().createPosition(x,y)))
            .flatMap(Function.identity());
}
```

We will call the update method from `makeMoves`:

```
updateUnseenLocations(gameState);
```

### Assign Players to Explore
All that remains to be done is to add a `doExploreUnseen` method to generate routes for each available player
to an unseen position and then assign them in much the same way as you did for collectables.

```
private List<Move> doExploreUnseen(final GameState gameState, final Map<Player, Position> assignedPlayerDestinations, final List<Position> nextPositions) {
    List<Move> exploreMoves = new ArrayList<>();

    Set<Player> players = gameState.getPlayers().stream()
            .filter(player -> isMyPlayer(player))
            .filter(player -> !assignedPlayerDestinations.containsKey(player))
            .collect(Collectors.toSet());

    List<Route> unseenRoutes = generateRoutes(gameState, players, unseenPositions);

    Collections.sort(unseenRoutes);
    exploreMoves.addAll(assignRoutes(gameState, assignedPlayerDestinations, nextPositions, unseenRoutes));

    System.out.println(exploreMoves.size() + " players exploring unseen");
    return exploreMoves;
}
```

You will need to add a call to this method after the `doCollect` call:

```
moves.addAll(doExploreUnseen(gameState, assignedPlayerDestinations, nextPositions));
```

### Testing

Your upgraded Bot is ready and eager to go into battle, so run another game as before:

Windows command prompt:

```batch
gradlew run -P mainClass=<your_bot_class_fully_qualified_name>
```

Unix shell:

```sh
./gradlew run -P mainClass=<your_bot_class_fully_qualified_name>
```

Your players should now be exploring the map and collecting all visible food, with the result that your Bot will
almost certainly survive to the `TURN_LIMIT_REACHED` end condition every time. If you're lucky you might even manage
to wander onto an enemy spawn point and end the game early... How about adding that as another goal before gathering
collectables and exploring? See the [next step](5-destroying-spawn-points.md) for more details.

## Extra Credit

### Available Players
Reviewing your code you can probably spot a number of blocks of code which are virtually identical, e.g. obtaining a
stream of unassigned players; perhaps that could be refactored into a utility method?

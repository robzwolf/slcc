# Tutorial
The default behaviour of the example Bot could not be any worse, it was only included to allow the set-up to be
validated, so let's take a look at how it could be improved.

## The Plan
This step-by-step tutorial will walk you through the process of adding some useful behaviour to your Bot and hopefully
you should start to win some of those games against the default Bot and be able to take on some of the more sophisticated
Bots included in the starter kit.

Along with the example Bot the starter kit includes some helper functions that you will make use of when adding the new
features, see `com.scottlogic.hackathon.game.GameMap` for more details.

### Step One
Moving each player away from the spawn point will allow the next player to appear without eliminating both itself and
the previous player, see [adding player movement](1-adding-player-movement.md).

### Step Two
Now that your players are moving around the map your games will be lasting slightly longer.  Unfortunately, due to the
naive approach adopted, your players are now marching north and into the water to drown, let's fix that and also ensure
that they don't [collide with each other](2-avoiding-out-of-bounds.md).

### Step Three
So your players can now move around the map and don't drown or eliminate each other by accident, but what about all
that food that keeps appearing, how do you [gather enough items](3-gathering-collectables.md) to ensure that your army
continues to grow?

### Step Four
If your players cannot see anything to collect they just stand still and wait for something to appear which is not the
best approach, they should be [exploring the map](4-exploring-the-map.md) to increase the chances of spotting
collectables. 

### Step Five
The best defence is a strong offence, the best way to prevent players from other Bots from attacking you is to prevent
them from spawning more players.  You can do this by moving a player onto their spawn point to
[destroy it](5-destroying-spawn-points.md).

## Next steps
This tutorial should have improved the capabilities of your Bot to give it a fighting chance, but there is definitely
more that could be done, here are a few ideas:

- the routing algorithm is very basic and assumes your players can travel over water, perhaps some form of path finding
would work better in more complex maps. The `com.scottlogic.hackathon.game.GameMap.findRoute()` method may help you here
- the battle rules are such that your players can eliminate enemy players without taking losses, you could add some
logic to ensure you outnumber your enemies
- be careful that you don't leave your own spawn point undefended, if it gets destroyed then you cannot spawn more
players which will probably mean that you'll lose the game in the long run
- the exploration code could mean that your players tend to ignore areas of the map that have been visited previously
which might mean that collectable items will get overlooked, perhaps some form of revisting logic is needed
- the player behaviour is currently hard-coded to collect items first before attacking spawn points, perhaps it might
make more sense to attack first if you have plenty of players available

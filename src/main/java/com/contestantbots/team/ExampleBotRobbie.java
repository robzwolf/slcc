package com.contestantbots.team;

import com.contestantbots.util.GameStateLogger;
import com.scottlogic.hackathon.client.Client;
import com.scottlogic.hackathon.game.*;

import java.util.*;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

public class ExampleBotRobbie extends Bot {
    private final GameStateLogger gameStateLogger;

    public ExampleBotRobbie() {
        super("Example Bot");
        gameStateLogger = new GameStateLogger(getId());
    }

    @Override
    public List<Move> makeMoves(final GameState gameState) {
        gameStateLogger.process(gameState);
        List<Move> moves = new ArrayList<>();
        List<Position> nextPositions = new ArrayList<>();
        moves.addAll(doExplore(gameState, nextPositions));
        return moves;
    }

    private boolean canMove(final GameState gameState, final List<Position> nextPositions, final Player player, final Direction direction) {
        Set<Position> outOfBounds = gameState.getOutOfBoundsPositions();
        Position newPosition = gameState.getMap().getNeighbour(player.getPosition(), direction);
        if (!nextPositions.contains(newPosition)) {
            nextPositions.add(newPosition);
            return true;
        }
        return false;
    }

    private List<Move> doExplore(final GameState gameState, final List<Position> nextPositions) {
        List<Move> exploreMoves = new ArrayList<>();

        exploreMoves.addAll(gameState.getPlayers().stream()
                .filter(player -> isMyPlayer(player))
                .map(player -> doMove(gameState, nextPositions, player))
                .collect(Collectors.toList()));

        System.out.println(exploreMoves.size() + " players exploring");
        return exploreMoves;
    }

    private boolean isMyPlayer(final Player player) {
        return player.getOwner().equals(getId());
    }

    private Move doMove(final GameState gameState, final List<Position> nextPositions, final Player player) {
        List<Direction> directions = new ArrayList<>(Arrays.asList(Direction.values()));
        Direction direction;
        do {
            direction = directions.remove(ThreadLocalRandom.current().nextInt(directions.size()));
        } while (!directions.isEmpty() && !canMove(gameState, nextPositions, player, direction));
        return new MoveImpl(player.getId(), direction);
    }


    /*
     * Run this main as a java application to test and debug your code within your IDE.
     * After each turn, the current state of the game will be printed as an ASCII-art representation in the console.
     * You can study the map before hitting 'Enter' to play the next phase.
     */
    public static void main(String ignored[]) throws Exception {

        final String[] args = new String[]{
                /*
                Pick the map to play on
                -----------------------
                Each successive map is larger, and has more out-of-bounds positions that must be avoided.
                Make sure you only have ONE line uncommented below.
                 */
                "--map",
//                    "VeryEasy",
                    "Easy",
//                    "Medium",
//                    "LargeMedium",
//                    "Hard",

                /*
                Pick your opponent bots to test against
                ---------------------------------------
                Every game needs at least one opponent, and you can pick up to 3 at a time.
                Uncomment the bots you want to face, or specify the same opponent multiple times to face multiple
                instances of the same bot.
                 */
                "--bot",
//                    "Default", // Players move in random directions
                    "Milestone1", // Players just try to stay out of trouble
//                    "Milestone2", // Some players gather collectables, some attack enemy players, and some attack enemy spawn points
//                    "Milestone3", // Strategy dynamically updates based on the current state of the game

                /*
                Enable debug mode
                -----------------
                This causes all Bots' 'makeMoves()' methods to be invoked from the main thread,
                and prevents them from being disqualified if they take longer than the usual time limit.
                This allows you to run in your IDE debugger and pause on break points without timing out.

                Comment this line out if you want to check that your bot is running fast enough.
                 */
                "--debug",

                // Use this class as the 'main' Bot
                "--className", ExampleBotRobbie.class.getName()
        };

        Client.main(args);
    }

    static class MoveImpl implements Move {
        private UUID playerId;
        private Direction direction;
        MoveImpl(UUID playerId, Direction direction) {
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

}

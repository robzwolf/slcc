package com.contestantbots.util;

import com.scottlogic.hackathon.game.Collectable;
import com.scottlogic.hackathon.game.GameState;
import com.scottlogic.hackathon.game.Player;
import com.scottlogic.hackathon.game.Position;
import com.scottlogic.hackathon.game.SpawnPoint;

import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

public class GameStateLogger {
    private UUID botId;

    public GameStateLogger(UUID botId) {
        this.botId = botId;
    }

    public void process(GameState gameState) {
        renderSeparator(true);
        System.out.println("turn: " + gameState.getPhase() + "\n" +
                "map: " + gameState.getMap().getWidth() + " wide by " + gameState.getMap().getHeight() + " high");
        renderSeparator(true);

        StringBuilder outOfBoundsOutput = new StringBuilder("Out of Bounds");
        Set<Position> outOfBounds = gameState.getOutOfBoundsPositions();
        if (outOfBounds.isEmpty()) {
            outOfBoundsOutput.append(": none visible");
        } else {
            outOfBounds.forEach(outOfBound -> outOfBoundsOutput.append("\n").append(outOfBound));
        }
        System.out.println(outOfBoundsOutput);
        renderSeparator(true);

        renderSpawnPoints(gameState);
        renderPlayers(gameState);

        StringBuilder collectablesOutput = new StringBuilder("Collectables");
        Set<Collectable> collectables = gameState.getCollectables();
        if (collectables.isEmpty()) {
            collectablesOutput.append(": none visible");
        } else {
            collectables.forEach(collectable -> collectablesOutput.append("\n").append(collectable));
        }
        System.out.println(collectablesOutput);
        renderSeparator(true);
        System.out.println();
        System.out.println();
    }

    private void renderSpawnPoints(GameState gameState) {
        List<SpawnPoint> friendlySpawnPoints = gameState.getSpawnPoints()
                .stream()
                .filter(spawnPoint -> spawnPoint.getOwner().equals(botId))
                .collect(Collectors.toList());
        List<SpawnPoint> enemySpawnPoints = gameState.getSpawnPoints()
                .stream()
                .filter(spawnPoint -> !spawnPoint.getOwner().equals(botId))
                .collect(Collectors.toList());
        Set<SpawnPoint> removedSpawnPoints = gameState.getRemovedSpawnPoints();

        System.out.println("SpawnPoints");
        StringBuilder friendly = new StringBuilder("Friendly");
        if (friendlySpawnPoints.isEmpty()) {
            friendly.append(": none");
        } else {
            friendlySpawnPoints.forEach(spawnPoint -> friendly.append("\n").append(spawnPoint));
        }
        System.out.println(friendly);
        renderSeparator(false);
        StringBuilder enemy = new StringBuilder("Enemy");
        if (enemySpawnPoints.isEmpty()) {
            enemy.append(": none visible");
        } else {
            enemySpawnPoints.forEach(spawnPoint -> enemy.append("\n").append(spawnPoint));
        }
        System.out.println(enemy);
        renderSeparator(false);
        StringBuilder removed = new StringBuilder("Removed");
        if (removedSpawnPoints.isEmpty()) {
            removed.append(": none");
        } else {
            removedSpawnPoints.forEach(spawnPoint -> removed.append("\n").append(spawnPoint));
        }
        System.out.println(removed);
        renderSeparator(true);
    }

    private void renderPlayers(GameState gameState) {
        List<Player> friendlyPlayers = gameState.getPlayers()
                .stream()
                .filter(player -> player.getOwner().equals(botId))
                .collect(Collectors.toList());
        List<Player> enemyPlayers = gameState.getPlayers()
                .stream()
                .filter(player -> !player.getOwner().equals(botId))
                .collect(Collectors.toList());
        Set<Player> removedPlayers = gameState.getRemovedPlayers();

        System.out.println("Players");
        StringBuilder friendly = new StringBuilder("Friendly");
        friendlyPlayers.forEach(player -> friendly.append("\n").append(player));
        System.out.println(friendly);
        renderSeparator(false);
        StringBuilder enemy = new StringBuilder("Enemy");
        if (enemyPlayers.isEmpty()) {
            enemy.append(": none visible");
        } else {
            enemyPlayers.forEach(player -> enemy.append("\n").append(player));
        }
        System.out.println(enemy);
        renderSeparator(false);
        StringBuilder removed = new StringBuilder("Removed");
        if (removedPlayers.isEmpty()) {
            removed.append(": none");
        } else {
            removedPlayers.forEach(player -> removed.append("\n").append(player));
        }
        System.out.println(removed);
        renderSeparator(true);
    }

    private void renderSeparator(boolean section) {
        if (section) {
            System.out.println("====================================================================================================");
        } else {
            System.out.println("----------------------------------------------------------------------------------------------------");
        }
    }
}

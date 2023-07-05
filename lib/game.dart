import 'package:darq/darq.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/game_configuration.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:vampulv/roles/role.dart';
import 'package:xrandom/xrandom.dart';

part 'game.freezed.dart';

// A position in a game of vampulv. A list of events and a configuration chould be enough to recreate a game from scratch.
@freezed
class Game with _$Game {
  const factory Game({
    required Xorshift32 randomGenerator,
    required List<Player> players,
  }) = _Game;

  const Game._();

  factory Game.fromConfiguration(GameConfiguration configuration) {
    assert(configuration.roles.length >= configuration.players.length * configuration.rolesPerPlayer);
    final randomGenerator = Xorshift32(configuration.randomSeed);
    final players = <Player>[];
    final shuffledRoles = configuration.roles.randomize().toList();
    for (int i = 0; i < configuration.players.length; i++) {
      players.add(Player(
        configuration: configuration.players[i],
        roles: shuffledRoles
            .sublist(
              configuration.rolesPerPlayer * i,
              configuration.rolesPerPlayer * (i + 1),
            )
            .map((roleType) => Role.fromType(roleType))
            .toList(),
        lives: configuration.maxLives,
      ));
    }
    return Game(
      randomGenerator: randomGenerator,
      players: players,
    );
  }

  factory Game.fromEvents(GameConfiguration configuration, List<NetworkMessage> events) {
    Game game = Game.fromConfiguration(configuration);
    for (NetworkMessage event in events) {
      game = game.applyChange(event);
    }
    return game;
  }

  Game applyChange(NetworkMessage change) {
    throw UnimplementedError();
  }
}

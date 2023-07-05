import 'package:vampulv/game.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/vampulv.dart';

abstract class Role {
  //Game changesBeforeNight(Game game) => game;
  List<RoleReaction> reactions;
  Role({this.reactions = const []});
  factory Role.fromType(RoleType roleType) => switch (roleType) {
        RoleType.vampulv => Vampulv(),
        _ => throw UnimplementedError(),
      };
}

class RoleReaction<T extends Event> {
  int priority;

  /// Must return Game to set entire game, Player to set owner or InputHandler to add an input handler to the owner.
  dynamic Function(Game game, Player owner) applyer;

  RoleReaction({required this.priority, required this.applyer});
}

enum RoleType {
  vampulv(),
  villger(),
  seer();

  const RoleType();
}

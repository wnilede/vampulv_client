import 'package:vampulv/game.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/role_type.dart';

abstract class Role {
  //Game changesBeforeNight(Game game) => game;
  List<RoleReaction> reactions;
  RoleType type;
  Role({required this.type, List<RoleReaction>? reactions}) : reactions = reactions ?? [];
}

class RoleReaction<T extends Event> {
  int priority;
  EventType? filter;

  /// Must return value that the game knows how to apply.
  dynamic Function(Event event, Game game, Player owner) applyer;

  RoleReaction({required this.priority, required this.applyer, this.filter});
}

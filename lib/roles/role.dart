import 'package:vampulv/game.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/role_type.dart';

abstract class Role {
  List<RoleReaction> reactions;
  RoleType type;
  Map<String, String> getDisplayableProperties(Game game, Player owner) => {};
  Role({required this.type, List<RoleReaction>? reactions}) : reactions = reactions ?? [];
}

class RoleReaction<T extends Event> {
  final int priority;
  final dynamic Function(T event, Game game, Player owner) _onApply;
  final bool worksAfterDeath;

  const RoleReaction({
    required this.priority,
    this.worksAfterDeath = false,

    /// Must return value that the game knows how to apply.
    required dynamic Function(T, Game, Player) onApply,
  }) : _onApply = onApply;

  bool passesFilter(Event event) {
    return event is T;
  }

  dynamic apply(Event event, Game game, Player owner) => _onApply(event as T, game, owner);
}

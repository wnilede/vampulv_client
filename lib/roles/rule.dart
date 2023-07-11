import 'package:vampulv/game.dart';
import 'package:vampulv/roles/event.dart';

abstract class Rule {
  List<RuleReaction> reactions;
  Rule({this.reactions = const []});
}

class RuleReaction<T extends Event> {
  int priority;
  EventType? filter;

  /// Must return value that the game knows how to apply.
  dynamic Function(Event event, Game game) applyer;

  RuleReaction({required this.priority, required this.applyer, this.filter});
}

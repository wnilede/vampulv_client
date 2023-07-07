import 'package:vampulv/game.dart';
import 'package:vampulv/roles/event.dart';

abstract class Rule {
  List<RuleReaction> reactions;
  Rule({this.reactions = const []});
}

class RuleReaction<T extends Event> {
  int priority;

  /// Must return null to change nothing, Game to set entire game or Event to add it to the game.
  dynamic Function(Event event, Game game) applyer;

  RuleReaction({required this.priority, required this.applyer});
}

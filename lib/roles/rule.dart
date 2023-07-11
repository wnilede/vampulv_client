import 'package:vampulv/game.dart';
import 'package:vampulv/roles/event.dart';

abstract class Rule {
  List<RuleReaction> reactions;
  Rule({this.reactions = const []});
}

class RuleReaction<T extends Event> {
  final int priority;
  final dynamic Function(T event, Game game) _onApply;

  const RuleReaction({
    required this.priority,

    /// Must return value that the game knows how to apply.
    required dynamic Function(T, Game) onApply,
  }) : _onApply = onApply;

  bool passesFilter(Event event) {
    return event is T;
  }

  dynamic apply(Event event, Game game) => _onApply(event as T, game);
}

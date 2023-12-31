import 'event.dart';
import 'game.dart';

abstract class Rule {
  List<RuleReaction> reactions;

  Rule({List<RuleReaction>? reactions}) : reactions = reactions ?? [];

  Map<String, dynamic> toJson() => {'type': runtimeType.toString()};
  factory Rule.fromJson(Map<String, dynamic> json) => throw UnsupportedError('Cannot deserialize Rule.');
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

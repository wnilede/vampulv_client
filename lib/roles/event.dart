class Event {
  EventType type;

  /// Determines in which order events of the same type are evaluated. Set to null only if it is known that there will never be another event of this type before this one has been applied, and that there are no currently unapplied events of this type.
  int? priority;

  Event({required this.type, this.priority});
}

enum EventType {
  // The order determines which order they are evaluated in
  nightBegins,
  vampulvsAttacks,
  dayBegins,
  gameEnds,
}

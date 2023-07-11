import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/roles/vampulv.dart';

abstract class Event {
  /// Determines in which order events of different types are evaluated. Types not present should not be put in the unhandledEvent.
  static const typeOrder = [
    GameEndsEvent,
    GameBeginsEvent,
    ProposeLynchingEvent,
    VampulvsAttackEvent,
    HurtEvent,
    DieEvent,
    NightBeginsEvent,
    DayBeginsEvent,
  ];

  /// Determines in which order events of the same type are evaluated. Set to null only if it is known that there will never be another event of this type before this one has been applied, and that there are no currently unapplied events of this type.
  int? priority;

  Event({this.priority});
}

enum EventResult {
  cancel,
}

import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/roles/vampulv.dart';

abstract class Event {
  /// Determines in which order events of different types are evaluated. Types of the same type are evaluated in the order they added. Types not present should not be put in the unhandledEvent. Subtypes with instances that always have appliedMorning set to false should not be in this list.
  static const typeOrder = [
    VampulvsAttackEvent,
    HurtEvent,
    DieEvent,
  ];

  bool appliedMorning;

  Event({this.appliedMorning = false});
}

enum EventResult {
  cancel,
}

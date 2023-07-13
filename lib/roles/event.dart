import 'package:vampulv/roles/standard_events.dart';

abstract class Event {
  /// Determines in which order events of different types are evaluated. Types of the same type are evaluated in the order they added. Types not present should not be put in the unhandledEvent. Subtypes with instances that always have appliedMorning set to false should not be in this list.
  static const typeOrder = [
    HurtEvent,
    DieEvent,
  ];

  bool appliedMorning;

  Event({this.appliedMorning = false}) {
    assert(!appliedMorning || typeOrder.contains(runtimeType), "Cannot instanciate Event because it have appliedMorning set to false, and it's subtype '$runtimeType' is not in the typeOrder field.");
  }
}

enum EventResult {
  cancel,
}

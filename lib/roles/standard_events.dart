import 'package:vampulv/roles/event.dart';

class HurtEvent extends Event {
  int playerId;
  int livesLost;

  HurtEvent({required this.playerId, this.livesLost = 1, super.priority}) : super(type: EventType.playerIsHurt);
}

class DieEvent extends Event {
  int playerId;

  DieEvent({required this.playerId, super.priority}) : super(type: EventType.playerDies);
}

class NightBeginsEvent extends Event {
  int nightIndex;
  NightBeginsEvent(this.nightIndex) : super(type: EventType.nightBegins);
}

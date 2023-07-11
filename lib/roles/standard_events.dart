import 'package:vampulv/roles/event.dart';

class HurtEvent extends Event {
  int playerId;
  int livesLost;

  HurtEvent({required this.playerId, this.livesLost = 1, super.priority}) : super(type: EventType.playerIsHurt);
}

class NightBeginsEvent extends Event {
  int nightIndex;
  NightBeginsEvent(this.nightIndex) : super(type: EventType.nightBegins);
}

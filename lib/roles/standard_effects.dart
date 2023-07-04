import 'package:vampulv/roles/event.dart';

class NightBeginsEvent extends Event {
  int nightIndex;
  NightBeginsEvent(this.nightIndex) : super(type: EventType.nightBegins);
}

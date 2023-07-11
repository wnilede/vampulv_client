import 'package:vampulv/network/message_bodies/propose_lynching_body.dart';
import 'package:vampulv/roles/event.dart';

class HurtEvent extends Event {
  int playerId;
  int livesLost;

  HurtEvent({required this.playerId, this.livesLost = 1, required super.priority});
}

class DieEvent extends Event {
  int playerId;

  DieEvent({required this.playerId, required super.priority});
}

class GameBeginsEvent extends Event {}

class GameEndsEvent extends Event {}

class NightBeginsEvent extends Event {}

class DayBeginsEvent extends Event {}

class ProposeLynchingEvent extends Event {
  int proposerId;
  int proposedId;

  ProposeLynchingEvent({required this.proposedId, required this.proposerId});

  factory ProposeLynchingEvent.fromBody(ProposeLynchingBody body) => ProposeLynchingEvent(proposedId: body.proposedId, proposerId: body.proposerId);
}

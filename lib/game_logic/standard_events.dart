import '../network/message_bodies/propose_lynching_body.dart';
import 'event.dart';

class HurtEvent extends Event {
  int playerId;
  int livesLost;

  HurtEvent({required this.playerId, this.livesLost = 1, required super.appliedMorning});
}

class DieEvent extends Event {
  int playerId;

  DieEvent({required this.playerId, required super.appliedMorning});
}

class GameBeginsEvent extends Event {}

class GameEndsEvent extends Event {}

class EndScoringEvent extends Event {}

class NightBeginsEvent extends Event {}

class DayBeginsEvent extends Event {}

class ProposeLynchingEvent extends Event {
  int proposerId;
  int proposedId;

  ProposeLynchingEvent({required this.proposedId, required this.proposerId});

  factory ProposeLynchingEvent.fromBody(ProposeLynchingBody body) =>
      ProposeLynchingEvent(proposedId: body.proposedId, proposerId: body.proposerId);
}

class LynchingDieEvent extends DieEvent {
  LynchingDieEvent({required super.playerId}) : super(appliedMorning: false);
}

import 'package:vampulv/game.dart';

abstract class Role {
  //Game changesBeforeNight(Game game) => game;
  List<Reaction> reactions;
  Role({this.reactions = const []});
}

class Effect {
  int priority;
  Effect(this.priority);
}

class Reaction {
  int priority;
  Game Function(Game) applyer;
  Reaction(this.priority, this.applyer);
}

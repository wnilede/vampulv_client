import 'dart:math' as math;

import 'package:darq/darq.dart';

import '../components/player_map.dart';
import '../game_logic/game.dart';
import '../game_logic/player.dart';
import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import '../game_logic/standard_events.dart';
import '../input_handlers/input_handler.dart';
import '../utility/list_strings_nicely.dart';

class Hoodler extends Role {
  static const int numberOfTargets = 2;
  static const int nightWaking = 2;
  List<int>? targets;

  Hoodler() : super(type: RoleType.hoodler) {
    reactions.add(RoleReaction<NightBeginsEvent>(
      priority: -27,
      worksAfterDeath: true,
      onApply: (event, game, player) => game.dayNumber >= nightWaking && targets == null
          ? HoodlerTargetsInputHandler(
              setTargets: (targets) {
                this.targets = targets;
              },
              numberOfTargets: math.min(numberOfTargets, game.alivePlayers.where((other) => other.id != player.id).count()),
            )
          : null,
    ));
    reactions.add(RoleReaction<EndScoringEvent>(
      priority: 8,
      worksAfterDeath: true,
      onApply: (event, game, player) => player.copyWith(
        isWinner: targets != null && targets!.every((targetId) => !game.playerFromId(targetId).alive),
      ),
    ));
  }

  @override
  Map<String, String> getDisplayableProperties(Game game, Player owner) => targets == null
      ? {
          'Hoodlade': 'Inga spelare valda än',
        }
      : targets!.indexed.toMap((indexTarget) => MapEntry('Hoodlad ${indexTarget.$1}', game.playerFromId(indexTarget.$2).name));
}

class HoodlerTargetsInputHandler extends InputHandler {
  HoodlerTargetsInputHandler({required void Function(List<int>) setTargets, required int numberOfTargets})
      : super(
          title: 'Hoodler',
          description: 'Välj spelare för hoodlern',
          resultApplyer: (input, game, player) {
            final targets = input.message == 'none'
                ? <int>[]
                : input.message //
                    .split(';')
                    .map((stringId) => int.parse(stringId))
                    .toList();
            setTargets(targets);
            return targets.isEmpty
                ? 'Det fanns ingen kvar för din hoodler att välja, så du uppfyller vinstvillkoret automatiskt.'
                : 'Du valde ${targets.map((target) => game.playerFromId(target).name).listedNicelyAnd} för din hoodler.';
          },
          widget: PlayerMap(
            numberSelected: numberOfTargets,
            description: 'Välj spelare att använda hoodlern på',
            canSelectSelf: false,
            onDone: null,
          ),
        );
}

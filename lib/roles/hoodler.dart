import 'dart:math' as math;

import 'package:darq/darq.dart';

import '../components/player_map.dart';
import '../game_logic/game.dart';
import '../game_logic/player.dart';
import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import '../game_logic/rule.dart';
import '../game_logic/standard_events.dart';
import '../input_handlers/input_handler.dart';
import '../utility/list_strings_nicely.dart';

class Hoodler extends Role {
  static const int numberOfTargets = 2;
  static const int nightWaking = 2;
  List<int>? targets;

  Hoodler() : super(type: RoleType.hoodler) {
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
      : targets!.indexed.toMap(
          (indexTarget) => MapEntry('Hoodlad ${indexTarget.$1 + 1}', game.playerFromId(indexTarget.$2).name),
          modifiable: true,
        );
}

class HoodlerTargetsInputHandler extends InputHandler {
  HoodlerTargetsInputHandler({required void Function(List<int>) setTargets, required int numberOfTargets})
      : super(
          title: 'Hoodler',
          description: 'Välj spelare för &hoodler',
          resultApplyer: (input, game, player) {
            final targets = input.message == 'none'
                ? <int>[]
                : input.message //
                    .split(';')
                    .map((stringId) => int.parse(stringId))
                    .toList();
            setTargets(targets);
            return targets.isEmpty
                ? 'Det fanns ingen kvar för din &hoodler att välja, så du uppfyller vinstvillkoret automatiskt.'
                : 'Du valde ${targets.map((target) => game.playerFromId(target).name).listedNicelyAnd} för din &hoodler.';
          },
          widget: PlayerMap(
            numberSelected: numberOfTargets,
            description: 'Välj spelare att använda &hoodler på',
            canSelectSelf: false,
            onDone: null,
          ),
        );
}

class HoodlerRule extends Rule {
  HoodlerRule()
      : super(reactions: [
          // This is a RuleReaction instead of a RoleReaction because it applies to everyone having at least one hoodler, and it is important that it is not run multiple times for the same player.
          RuleReaction<NightBeginsEvent>(
            priority: -27,
            onApply: (event, game) => game.dayNumber >= Hoodler.nightWaking
                ? game.players
                    .where((player) => player.roles.any((role) => role is Hoodler && role.targets == null))
                    .map((player) => player.copyWith(
                        unhandledInputHandlers: player.unhandledInputHandlers
                            .append(HoodlerTargetsInputHandler(
                              setTargets: (targets) {
                                for (Hoodler hoodler in player.roles.whereType<Hoodler>()) {
                                  hoodler.targets = targets;
                                }
                              },
                              numberOfTargets: math.min(
                                Hoodler.numberOfTargets * player.roles.whereType<Hoodler>().count(),
                                game.alivePlayers.where((other) => other.id != player.id).count(),
                              ),
                            ))
                            .toList()))
                : null,
          )
        ]);
}

import 'dart:math' as math;

import 'package:darq/darq.dart';
import 'package:vampulv/game.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/user_maps/user_map.dart';

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
          description: 'Välj spelare för hoodlern',
          identifier: 'hoodler-choose-target',
          resultApplyer: (input, game, player) {
            setTargets(input.message == 'none'
                ? []
                : input.message //
                    .split(';')
                    .map((stringId) => int.parse(stringId))
                    .toList());
          },
          widget: PlayerMap(
            identifier: 'hoodler-choose-target',
            numberSelected: numberOfTargets,
            description: 'Välj spelare att använda hoodlern på',
            canSelectSelf: false,
          ),
        );
}

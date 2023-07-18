import 'dart:math' as math;

import 'package:darq/darq.dart';
import 'package:vampulv/game.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/log_entry.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/role_type.dart';
import 'package:vampulv/roles/standard_events.dart';
import 'package:vampulv/user_maps/user_map.dart';

class Cupid extends Role {
  static const int numberOfTargets = 2;
  static const int nightWaking = 2;
  List<int>? targets;

  Cupid() : super(type: RoleType.cupid) {
    reactions.add(RoleReaction<NightBeginsEvent>(
      priority: -23,
      worksAfterDeath: false,
      onApply: (event, game, player) => game.dayNumber >= nightWaking && targets == null
          ? CupidTargetsInputHandler(
              setTargets: (targets) {
                this.targets = targets;
              },
              numberOfTargets: math.min(numberOfTargets, game.alivePlayers.count()),
            )
          : null,
    ));
    reactions.add(RoleReaction<DieEvent>(
      priority: 8,
      worksAfterDeath: true,
      onApply: (event, game, player) {
        if (targets == null || !targets!.contains(event.playerId)) {
          return null;
        }
        final playersHurting = targets!.where((target) => target != event.playerId && game.playerFromId(target).alive);
        return playersHurting
            .map((target) => [
                  HurtEvent(playerId: target, appliedMorning: false),
                  LogEntry(
                    playerVisibleTo: null,
                    value: 'På grund av att ${game.playerFromId(event.playerId).name} dör så förlorar ${game.playerFromId(target).name} ett liv av hjärtesorg.',
                  ),
                ])
            .toList();
      },
    ));
  }

  @override
  Map<String, String> getDisplayableProperties(Game game, Player owner) => targets == null
      ? {
          'Cupidade': 'Inga spelare valda än',
        }
      : targets!.indexed.toMap((indexTarget) => MapEntry('Cupidad ${indexTarget.$1}', game.playerFromId(indexTarget.$2).name));
}

class CupidTargetsInputHandler extends InputHandler {
  CupidTargetsInputHandler({required void Function(List<int>) setTargets, required int numberOfTargets})
      : super(
          description: 'Välj spelare att cupida',
          identifier: 'cupid-choose-target',
          resultApplyer: (input, game, player) {
            setTargets(input.message == 'none'
                ? []
                : input.message //
                    .split(';')
                    .map((stringId) => int.parse(stringId))
                    .toList());
          },
          widget: PlayerMap(
            identifier: 'cupid-choose-target',
            numberSelected: numberOfTargets,
            description: 'Välj spelare att använda cupid på',
          ),
        );
}
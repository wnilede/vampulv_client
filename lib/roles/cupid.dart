import 'dart:math' as math;

import 'package:darq/darq.dart';

import '../components/player_map.dart';
import '../game_logic/game.dart';
import '../game_logic/log_entry.dart';
import '../game_logic/player.dart';
import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import '../game_logic/standard_events.dart';
import '../input_handlers/input_handler.dart';
import '../utility/list_strings_nicely.dart';

class Cupid extends Role {
  static const int numberOfTargets = 2;
  static const int nightWaking = 2;
  List<int>? targets;

  Cupid() : super(type: RoleType.cupid) {
    reactions.add(RoleReaction<NightBeginsEvent>(
      priority: -23,
      onApply: (event, game, player) {
        final numberAllowedTargets = math.min(numberOfTargets, game.alivePlayers.count());
        return game.dayNumber >= nightWaking && targets == null
            ? CupidTargetsInputHandler(
                setTargets: (targets) {
                  this.targets = targets;
                },
                numberOfTargets: numberAllowedTargets == 1 ? 0 : numberAllowedTargets,
              )
            : null;
      },
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
                    value:
                        'På grund av att ${game.playerFromId(event.playerId).name} dör så förlorar ${game.playerFromId(target).name} ett liv av hjärtesorg&cupid.',
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
          title: 'Cupid',
          description: 'Välj spelare att cupida&cupid',
          resultApplyer: (input, game, player) {
            final targets = input.message == 'none'
                ? <int>[]
                : input.message //
                    .split(';')
                    .map((stringId) => int.parse(stringId))
                    .toList();
            setTargets(targets);
            return targets.isEmpty
                ? 'Det fanns inte kvar nog med spelare för din &cupid att välja.'
                : 'Du valde ${targets.map((target) => game.playerFromId(target).name).listedNicelyAnd} för din &cupid.';
          },
          widget: PlayerMap(
            numberSelected: numberOfTargets,
            description: 'Välj spelare att använda &cupid på',
            onDone: null,
          ),
        );
}

import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/game_logic/event.dart';
import 'package:vampulv/game_logic/role.dart';
import 'package:vampulv/game_logic/role_type.dart';
import 'package:vampulv/game_logic/standard_events.dart';
import 'package:vampulv/roles/vampulv.dart';
import 'package:vampulv/components/player_map.dart';

class Priest extends Role {
  int? protected;

  Priest() : super(type: RoleType.priest) {
    reactions.add(RoleReaction<NightBeginsEvent>(
      priority: 20,
      onApply: (event, game, player) => PriestTargetInputHandler((target) => protected = target, protected),
    ));
    reactions.add(RoleReaction<VampulvHurtEvent>(
      priority: 110,
      onApply: (event, game, player) => event.playerId == protected ? EventResult.cancel : null,
    ));
  }
}

class PriestTargetInputHandler extends InputHandler {
  PriestTargetInputHandler(Function(int? target) setTarget, int? lastProtected)
      : super(
          description: 'Välj spelare att använda prästen på',
          resultApplyer: (input, game, string) {
            final target = int.tryParse(input.message);
            setTarget(target);
            return target == null
                ? 'Du valde att inte använda din präst.'
                : 'Du använde din präst för att skydda ${game.playerFromId(target).name}.';
          },
          widget: PlayerMap(
            description: 'Välj någon att skydda mot vampulverna',
            numberSelected: 1,
            canChooseFewer: true,
            selectablePlayerFilter: [
              if (lastProtected != null) lastProtected,
            ],
            onDone: null,
          ),
        );
}

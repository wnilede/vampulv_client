import '../components/player_map.dart';
import '../game_logic/event.dart';
import '../game_logic/role.dart';
import '../game_logic/role_type.dart';
import '../game_logic/standard_events.dart';
import '../input_handlers/input_handler.dart';
import 'vampulv.dart';

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
          title: 'Präst',
          description: 'Välj spelare att använda &priest på',
          resultApplyer: (input, game, string) {
            final target = int.tryParse(input.message);
            setTarget(target);
            return target == null
                ? 'Du valde att inte använda din &priest.'
                : 'Du använde din &priest för att skydda ${game.playerFromId(target).name}.';
          },
          widget: PlayerMap(
            description: 'Välj någon att skydda mot vampulverna',
            numberSelected: 1,
            canChooseFewer: true,
            selectablePlayerFilter: [
              if (lastProtected != null) lastProtected,
            ],
            reasonForbidden: 'Du kan inte skydda samma spelare som förra natten.',
            onDone: null,
          ),
        );
}

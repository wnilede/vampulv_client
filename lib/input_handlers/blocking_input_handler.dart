import '../game_logic/game.dart';
import '../game_logic/player.dart';
import '../game_logic/player_input.dart';
import '../game_view/nothing_to_do_widget.dart';
import 'input_handler.dart';

class BlockingInputHandler extends InputHandler {
  BlockingInputHandler({required super.description})
      : super(
          title: null,
          widget: const NothingToDoWidget(canLyncha: false),
          resultApplyer: (PlayerInput input, Game game, Player owner) {},
        );
}

import 'package:vampulv/game_logic/game.dart';
import 'package:vampulv/game_view/nothing_to_do_widget.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/game_logic/player_input.dart';
import 'package:vampulv/game_logic/player.dart';

class BlockingInputHandler extends InputHandler {
  BlockingInputHandler()
      : super(
          description: 'Vampulv', // This is for the titel to not be spoiling, because the description is shown in the AppBar.
          widget: const NothingToDoWidget(canLyncha: false),
          resultApplyer: (PlayerInput input, Game game, Player owner) {},
        );
}

import 'package:vampulv/game.dart';
import 'package:vampulv/game_view/nothing_to_do_widget.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/network/player_input.dart';
import 'package:vampulv/player.dart';

class BlockingInputHandler extends InputHandler {
  BlockingInputHandler({required String identifier})
      : super(
          description: 'Vampulv', // This is for the titel to not be spoiling, because the description is shown in the AppBar.
          identifier: 'blocking-$identifier',
          widget: const NothingToDoWidget(),
          resultApplyer: (PlayerInput input, Game game, Player owner) {},
        );
}
import 'package:darq/darq.dart';
import 'package:vampulv/binary_choice.dart';
import 'package:vampulv/input_handlers/input_handler.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/standard_events.dart';

class LynchingVoteInputHandler extends InputHandler {
  LynchingVoteInputHandler({required Player proposer, required Player proposed})
      : super(
          description: 'Rösta i lynchning av ${proposed.configuration.name}',
          identifier: 'vote-lynching-of-${proposed.configuration.id}-proposed-by-${proposer.configuration.id}',
          resultApplyer: (playerInput, game, player) {
            // If this is the last player casting the vote, count the votes and send die event if neccessary.
            final newGame = game.copyWithPlayer(player.copyWith(lynchingVote: bool.parse(playerInput.message)));
            if (newGame.players.every((player) => player.lynchingVote != null) && newGame.players.sum((player) => player.lynchingVote! ? player.votesInLynching : -player.votesInLynching) > 0) {
              return [
                newGame,
                DieEvent(playerId: proposed.configuration.id, priority: 40, appliedMorning: false),
                NightBeginsEvent(),
              ];
            }
            return newGame;
          },
          widget: BinaryChoice(
            title: '${proposer.configuration.name} föreslår lynchning av ${proposed.configuration.name}',
            identifier: 'vote-lynching-of-${proposed.configuration.id}-proposed-by-${proposer.configuration.id}',
            trueChoice: 'För',
            falseChoice: 'Emot',
          ),
        );
}

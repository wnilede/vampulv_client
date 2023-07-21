import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import '../components/binary_choice.dart';
import '../input_handlers/confirm_child_input_handlers.dart';
import '../input_handlers/input_handler.dart';
import 'log_entry.dart';
import 'player.dart';
import 'standard_events.dart';

class LynchingVoteInputHandler extends InputHandler {
  LynchingVoteInputHandler({required Player proposer, required Player proposed})
      : super(
          description: 'Rösta i lynchning av ${proposed.name}',
          resultApplyer: (playerInput, game, player) {
            final newGame = game.copyWithPlayer(player.copyWith(lynchingVote: bool.parse(playerInput.message)));
            if (newGame.alivePlayers.any((player) => player.lynchingVote == null)) return newGame;

            // This is the last player casting the vote, so count the votes and send die event if neccessary.
            final summaries = newGame.alivePlayers.map((player) => '${player.name} röstade ${player.lynchingVote! ? 'för' : 'emot'}.');
            final result = [
              newGame,
              ...newGame.alivePlayers.map((player) => player.copyWith(
                  unhandledInputHandlers: player.unhandledInputHandlers
                      .where((inputHandler) => inputHandler is! LynchingWaitingResultInputHandler)
                      .append(EarlyConfirmChildInputHandler.withText(summaries.join('\n')))
                      .toList())),
              LogEntry(
                  value: '${proposer.name} föreslog lynchning av ${proposed.name}.${summaries.map((summary) => '\n - $summary').join()}',
                  playerVisibleTo: null),
            ];
            if (newGame.alivePlayers.sum((player) => player.lynchingVote! ? player.votesInLynching : -player.votesInLynching) > 0) {
              result.add(LynchingDieEvent(playerId: proposed.id));
              result.add(NightBeginsEvent());
            }
            return result;
          },
          widget: BinaryChoice(
            title: '${proposer.name} föreslår lynchning av ${proposed.name}',
            trueChoice: 'För',
            falseChoice: 'Emot',
          ),
        );
}

class LynchingWaitingResultInputHandler extends InputHandler {
  LynchingWaitingResultInputHandler()
      : super(
          description: 'Vänta på andra',
          resultApplyer: (input, game, player) {},
          widget: const Center(child: Text('Väntar på att andra ska rösta i lynchningen...')),
        );
}

import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../input_handlers/confirm_child_input_handlers.dart';
import '../input_handlers/input_handler.dart';
import '../network/connected_device_provider.dart';
import '../network/message_sender_provider.dart';
import 'log_entry.dart';
import 'player.dart';
import 'rule.dart';
import 'standard_events.dart';

class LynchingRule extends Rule {
  LynchingRule()
      : super(reactions: [
          // Set game night field when event is sent and reset lynchinging ability.
          RuleReaction<NightBeginsEvent>(
            priority: 0,
            onApply: (event, game) => game.players
                .map((player) => player.copyWith(
                      lynchingDone: !player.alive,
                      previouslyProposed: [],
                      votesInLynching: 1,
                    ))
                .toList(),
          ),
          // Add input handlers for voting when lynching is proposed.
          RuleReaction<ProposeLynchingEvent>(
            priority: 0,
            onApply: (event, game) {
              Player proposed = game.playerFromId(event.proposedId);
              Player proposer = game.playerFromId(event.proposerId);
              return game.alivePlayers.map(
                (player) {
                  if (player.id == proposer.id) {
                    player = player.copyWith(previouslyProposed: player.previouslyProposed.append(proposed.id).toList());
                  }
                  return player.copyWith(
                    lynchingVote: null,
                    unhandledInputHandlers:
                        player.unhandledInputHandlers.append(LynchingVoteInputHandler(proposer: proposer, proposed: proposed)).toList(),
                  );
                },
              ).toList();
            },
          ),
        ]);
}

class LynchingVoteInputHandler extends InputHandler {
  LynchingVoteInputHandler({required Player proposer, required Player proposed})
      : super(
          title: 'Lynching',
          description: 'Rösta i lynchning av ${proposed.name}',
          resultApplyer: (playerInput, game, player) {
            final newGame = game.copyWithPlayer(player.copyWith(lynchingVote: bool.tryParse(playerInput.message)));
            if (newGame.alivePlayers.any((player) => player.lynchingVote == null)) return newGame;

            // This is the last player casting the vote, so count the votes and send die event if neccessary.
            final summaries = newGame.alivePlayers.map((player) => '${player.name} röstade ${player.lynchingVote! ? 'för' : 'emot'}.');
            final result = [
              newGame,
              ...newGame.alivePlayers.map((player) => player.copyWith(
                  unhandledInputHandlers: player.unhandledInputHandlers
                      .where((inputHandler) => inputHandler is! LynchingVoteInputHandler)
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
          widget: LynchingVoteWidget(
            proposerName: proposer.name,
            proposedName: proposed.name,
          ),
        );
}

class LynchingVoteWidget extends ConsumerWidget {
  final String proposerName;
  final String proposedName;

  const LynchingVoteWidget({required this.proposerName, required this.proposedName, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              '$proposerName föreslår lynchning av $proposedName',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _VoteOption(value: true, title: 'För'),
            _VoteOption(value: null, title: 'Funderar'),
            _VoteOption(value: false, title: 'Emot'),
          ],
        ),
      ],
    );
  }
}

class _VoteOption extends ConsumerWidget {
  final bool? value;
  final String title;

  const _VoteOption({required this.value, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vote = ref.watch(controlledPlayerProvider.select((player) => player?.lynchingVote));
    return Expanded(
      child: Column(
        children: [
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
          Radio(
            value: value,
            groupValue: vote,
            onChanged: (value) => ref.read(cMessageSenderProvider).sendPlayerInput(value.toString(), removesInputHandler: false),
          ),
        ],
      ),
    );
  }
}

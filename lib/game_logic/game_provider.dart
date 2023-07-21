import 'package:darq/darq.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/synchronized_data_provider.dart';
import 'game.dart';

part 'game_provider.g.dart';

@riverpod
class CGame extends _$CGame {
  @override
  Game? build() {
    ref.listen(cSynchronizedDataProvider.select((synchronizedData) => synchronizedData.game), (previous, next) {
      if (state != null && previous != null && next.hasBegun && next.configuration == previous.configuration) {
        final pastFromNext = next.events.take(previous.events.length);
        final futureFromNext = next.events.skip(previous.events.length).toList();
        if (pastFromNext.sequenceEquals(previous.events) &&
            pastFromNext.every((pastEvent) => futureFromNext.every((futureEvent) => pastEvent.timestamp! <= futureEvent.timestamp!))) {
          state = state!.applyNetworkMessages(futureFromNext);
          return;
        }
      }
      ref.invalidateSelf();
    });

    // The riverpod documentation said not to use ref.read inside build, but in this case it should be alright, right?
    final game = ref.read(cSynchronizedDataProvider).game;
    if (!game.hasBegun) {
      return null;
    }
    return Game.fromSavedGame(game);
  }
}

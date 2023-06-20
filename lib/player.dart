import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';
part 'player.g.dart';

@freezed
class Player with _$Player {
  const factory Player({
    required String name,
    required int position,
  }) = _Player;

  factory Player.fromJson(Map<String, Object?> json) => _$PlayerFromJson(json);
}

class PlayerNotifier extends StateNotifier<Player> {
  PlayerNotifier()
      : super(const Player(
          name: '',
          position: -1,
        ));
}

final currentPlayerProvider = StateNotifierProvider<PlayerNotifier, Player>((ref) => PlayerNotifier());

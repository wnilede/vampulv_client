import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/game.dart';

part 'gameeffect.freezed.dart';

@freezed
class GameEffect with _$GameEffect {
  factory GameEffect({
    required int priority,
    required Game Function(Game game) effectApplyer,
  }) = _GameEffect;
}

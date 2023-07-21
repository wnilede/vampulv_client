import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_input.freezed.dart';
part 'player_input.g.dart';

@freezed
class PlayerInput with _$PlayerInput {
  const factory PlayerInput({
    required String message,
    required int ownerId,
    required int playerInputNumber,
  }) = _PlayerInput;
  factory PlayerInput.fromJson(Map<String, Object?> json) => _$PlayerInputFromJson(json);
  const PlayerInput._();

  Map<String, Object?> get body => json.decode(message);

  factory PlayerInput.fromObject({
    required int ownerId,
    required int playerInputNumber,
    required Object body,
  }) {
    return PlayerInput(
      ownerId: ownerId,
      playerInputNumber: playerInputNumber,
      message: body is String ? body : json.encode(body),
    );
  }
}

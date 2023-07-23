import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../game_logic/game_configuration.dart';
import '../game_logic/player_input.dart';
import '../utility/logger_providers.dart';
import 'connected_device_provider.dart';
import 'message_bodies/change_device_controls_body.dart';
import 'network_message.dart';
import 'network_message_type.dart';
import 'synchronized_data.dart';

part 'message_sender.freezed.dart';

@freezed
class MessageSender with _$MessageSender {
  factory MessageSender({
    required String? error,
    required WebSocketSink? sink,
    required Ref ref,
  }) = _MessageSender;
  factory MessageSender.connected(WebSocketSink sink, Ref ref) => MessageSender(error: null, sink: sink, ref: ref);
  factory MessageSender.loading(Ref ref) => MessageSender(error: null, sink: null, ref: ref);
  factory MessageSender.error(String error, Ref ref) => MessageSender(error: error, sink: null, ref: ref);
  const MessageSender._();

  bool get isConnected => sink != null;
  bool get isConnecting => sink == null && error == null;
  Logger get _logger => ref.read(networkLoggerProvider);

  void sendChange(NetworkMessage event) {
    if (event.timestamp == null) {
      event = event.copyWith(timestamp: DateTime.now().millisecondsSinceEpoch);
    }
    sendString(json.encode(event.toJson()));
  }

  void sendString(String message) {
    _logger.fine("Sending message '$message' to server.");
    if (sink != null) {
      sink!.add(message);
    }
  }

  void sendGameConfiguration(GameConfiguration configuration) {
    sendChange(NetworkMessage.fromObject(
      type: NetworkMessageType.setGameConfiguration,
      body: configuration,
    ));
  }

  void sendPlayerInput(Object value) {
    final player = ref.read(controlledPlayerProvider);
    if (player == null) return;
    sendChange(NetworkMessage.fromObject(
      type: NetworkMessageType.inputToGame,
      body: PlayerInput.fromObject(
        ownerId: player.id,
        playerInputNumber: player.handledInputs,
        body: value,
      ),
    ));
  }

  void sendDeviceControls(int deviceToChangeId, int? playerToControlId) {
    sendChange(NetworkMessage.fromObject(
      type: NetworkMessageType.changeDeviceControls,
      body: ChangeDeviceControlsBody(
        deviceToChangeId: deviceToChangeId,
        playerToControlId: playerToControlId,
      ),
    ));
  }

  void sendSynchronizedData(SynchronizedData synchronizedData) {
    sendChange(NetworkMessage.fromObject(
      type: NetworkMessageType.setSynchronizedData,
      body: synchronizedData,
    ));
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vampulv/game_configuration.dart';
import 'package:vampulv/network/connected_device_provider.dart';
import 'package:vampulv/network/message_bodies/change_device_controls_body.dart';
import 'package:vampulv/network/network_message.dart';
import 'package:vampulv/network/network_message_type.dart';
import 'package:vampulv/network/player_input.dart';
import 'package:vampulv/network/synchronized_data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'message_sender.freezed.dart';

@freezed
class MessageSender with _$MessageSender {
  factory MessageSender({
    WebSocketSink? sink,
    Stream<dynamic>? stream,
    required final Ref ref,
  }) = _MessageSender;
  const MessageSender._();

  bool get isConnected => sink != null && stream != null;

  void sendChange(NetworkMessage event) {
    if (event.timestamp == null) {
      event = event.copyWith(timestamp: DateTime.now().millisecondsSinceEpoch);
    }
    sendString(json.encode(event.toJson()));
  }

  void sendString(String message) {
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

  void sendPlayerInput(Object value, String identifier) {
    final player = ref.read(controlledPlayerProvider);
    if (player == null) return;
    sendChange(NetworkMessage.fromObject(
      type: NetworkMessageType.inputToGame,
      body: PlayerInput.fromObject(
        ownerId: player.id,
        playerInputNumber: player.handledInputs,
        identifier: identifier,
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

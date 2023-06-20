import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_message.freezed.dart';
part 'network_message.g.dart';

@freezed
class NetworkMessage with _$NetworkMessage {
  const factory NetworkMessage({
    required MessageType messageType,
    required String body,
  }) = _NetworkMessage;

  factory NetworkMessage.fromJson(Map<String, Object?> json) => _$NetworkMessageFromJson(json);
}

enum MessageType {
  entireGame,
  userInput,
}

// final StreamProvider<NetworkMessage> recievedMessagesProvider = StreamProvider<NetworkMessage>((ref) async* {
//   const port = 6353;
//   try {
//     final socket = await Socket.connect('vampulv', port, timeout: Duration(seconds: 30 + Random().nextInt(30)));
//     ref.onDispose(socket.close);

//     // When a client, simply convert the messages recieved to NetworkMessages and provide them.
//     yield* socket.map((message) => NetworkMessage.fromJson(json.decode(utf8.decode(message))));
//   } on SocketException {
//     // We did not manage to connect as a client. Retry as a server.
//     final socket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
//     ref.onDispose(socket.close);

//     List<Socket> clients = [];
//     await for (final client in socket) {
//       client.write(NetworkMessage(
//         messageType: MessageType.entireGame,
//         body: json.encode(ref.read(synchronizedDataProvider)),
//       ));
//       clients.add(client);
//       await for (final data in client) {
//         // We should provide the NetworkMessage list to ourself even as a server.
//         allMessages = [
//           ...allMessages,
//           NetworkMessage.fromJson(json.decode(utf8.decode(data))),
//         ];
//         yield allMessages;

//         // We also need to forward the message to every client (including the one that sent it).
//         for (final clientToForwardTo in clients) {
//           clientToForwardTo.write(data);
//         }
//       }
//     }
//   }
// });

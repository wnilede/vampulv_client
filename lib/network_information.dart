import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_information.freezed.dart';

@freezed
class NetworkInformation with _$NetworkInformation {
  const factory NetworkInformation(int hej) = _NetworkInformation;

  //void broadcastString() {}
}

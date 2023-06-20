import 'package:freezed_annotation/freezed_annotation.dart';

part 'synchronized_data_change.freezed.dart';
part 'synchronized_data_change.g.dart';

@freezed
class SynchronizedDataChange with _$SynchronizedDataChange {
  const factory SynchronizedDataChange({
    required SynchronizedDataChangeType type,
    required String message,
    int? timestamp,
  }) = _SynchronizedDataChange;

  factory SynchronizedDataChange.fromJson(Map<String, Object?> json) => _$SynchronizedDataChangeFromJson(json);
}

enum SynchronizedDataChangeType {
  addPlayer(changesGame: true),
  addDevice(changesGame: false),
  changeDeviceControls(changesGame: false);

  const SynchronizedDataChangeType({required this.changesGame});

  final bool changesGame;
}

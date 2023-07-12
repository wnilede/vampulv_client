import 'package:freezed_annotation/freezed_annotation.dart';

part 'set_done_lynching_body.freezed.dart';
part 'set_done_lynching_body.g.dart';

@freezed
class SetDoneLynchingBody with _$SetDoneLynchingBody {
  const factory SetDoneLynchingBody({
    required int playerId,
    required bool value,
  }) = _SetDoneLynchingBody;

  factory SetDoneLynchingBody.fromJson(Map<String, dynamic> json) => _$SetDoneLynchingBodyFromJson(json);
}

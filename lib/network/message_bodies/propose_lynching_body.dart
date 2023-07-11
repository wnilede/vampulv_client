import 'package:freezed_annotation/freezed_annotation.dart';

part 'propose_lynching_body.freezed.dart';
part 'propose_lynching_body.g.dart';

@freezed
class ProposeLynchingBody with _$ProposeLynchingBody {
  factory ProposeLynchingBody({
    required int proposerId,
    required int proposedId,
  }) = _ProposeLynchingBody;

  factory ProposeLynchingBody.fromJson(Map<String, dynamic> json) => _$ProposeLynchingBodyFromJson(json);
}

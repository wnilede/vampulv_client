import 'package:freezed_annotation/freezed_annotation.dart';

part 'logentry.freezed.dart';

@freezed
class LogEntry with _$LogEntry {
  factory LogEntry({
    required String value,
    required int? playerVisibleTo,
  }) = _LogEntry;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_entry.freezed.dart';
part 'log_entry.g.dart';

@freezed
class LogEntry with _$LogEntry {
  factory LogEntry({
    required String value,
    required int? playerVisibleTo,
  }) = _LogEntry;
  factory LogEntry.fromJson(Map<String, dynamic> json) => _$LogEntryFromJson(json);
}

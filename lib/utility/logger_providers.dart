import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logger_providers.g.dart';

@riverpod
class GeneralLogger extends _$GeneralLogger {
  @override
  Logger build() => Logger('General');
}

@riverpod
class NetworkLogger extends _$NetworkLogger {
  @override
  Logger build() => Logger('Network');
}

@riverpod
class GameLogger extends _$GameLogger {
  @override
  Logger build() => Logger('Game');
}

import 'package:logging/logging.dart';

class Loggers {
  static get general => Logger('General');
  static get network => Logger('Network');
  static get game => Logger('Game');
  static get synchronizedData => Logger('SynchronizedData');
}

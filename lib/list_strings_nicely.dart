import 'package:darq/darq.dart';

extension ListStringsNicely on Iterable<String> {
  String get listNicely {
    return length >= 2
        ? '${skipLast(1).join(', ')} och $last'
        : length == 1
            ? single
            : '';
  }
}

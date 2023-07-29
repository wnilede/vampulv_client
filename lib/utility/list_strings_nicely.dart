import 'package:darq/darq.dart';

extension ListStringsNicely on Iterable<String> {
  String get listedNicelyAnd {
    return length >= 2
        ? '${skipLast(1).join(', ')} och $last'
        : length == 1
            ? single
            : '';
  }

  String get listedNicelyOr {
    return length >= 2
        ? '${skipLast(1).join(', ')} eller $last'
        : length == 1
            ? single
            : '';
  }
}

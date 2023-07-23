import 'dart:convert';

import 'package:json_diff/json_diff.dart';

String summaryObjectDiff(Object? left, Object? right) {
  DiffNode node = JsonDiffer(json.encode(left), json.encode(right)).diff();
  node.prune();
  return node.toString();
}

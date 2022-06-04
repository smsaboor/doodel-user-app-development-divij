import 'package:flutter/foundation.dart';
import 'package:stack_trace/stack_trace.dart';

void logD(Object object) {
  var output = "${Trace.current().frames[1].location} | $object";

  final pattern = RegExp('.{1,1000}'); // 1000 is the size of each chunk
  pattern.allMatches(output).forEach((match) => debugPrint(match.group(0)));
}

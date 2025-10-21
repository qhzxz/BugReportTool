import 'package:bug_report_tool/logcat/logcat.dart';
import 'package:flutter/foundation.dart';

Future<bool> StopLogcatUsecase(String serial) async {
  final instance = await Logcat.getInstance();
  String? path = await instance.stopCapturing();
  return path != null;
}


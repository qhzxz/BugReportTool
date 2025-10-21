import 'package:bug_report_tool/logcat/logcat.dart';
import 'package:flutter/foundation.dart';

Future<String?> StopLogcatUsecase(String serial) async {
  final instance = await Logcat.getInstance();
  String? path = await instance.stopCapturing();
  return path;
}


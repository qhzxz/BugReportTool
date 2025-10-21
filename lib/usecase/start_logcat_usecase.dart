import 'dart:isolate';

import 'package:bug_report_tool/logcat/logcat.dart';
import 'package:flutter/foundation.dart';

import '../util/util.dart';

Future<String?> StartLogcatUsecase(String serial) async {
  final instance = await Logcat.getInstance();
  String? path = await instance.startCapturing(serial);
  print('adb 日志捕捉开始:$path');
  return path;
}

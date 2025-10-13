import 'dart:isolate';

import 'package:flutter/foundation.dart';

import '../util/util.dart';

Future<String?> StartLogcatUsecase(String serial) async {
  return compute(_StartLogcatUsecase, serial);
}

Future<String?> _StartLogcatUsecase(String serial) async {
  String time = getCurrentTimeFormatString();
  String path = '/sdcard/log_$time.txt';
  print('adb 日志捕捉开始:$path');
  Isolate.run(() async {
    await runCmd('adb', ['-s', serial, 'shell', 'logcat -f $path']);
  });
  return path;
}

import 'dart:isolate';

import 'package:flutter/foundation.dart';

import '../util/util.dart';

Future<String?> StartScreenRecordUsecase(String serial) async {
  return compute(_StartScreenRecordUsecase, serial);
}

Future<String?> _StartScreenRecordUsecase(String serial) async {
  String time = getCurrentTimeFormatString();
  String path = '/sdcard/video_$time.mp4';
  print('adb 录制视频开始:$path');
  Isolate.run(() async {
    await runCmd('adb', ['-s', serial, 'shell', 'screenrecord $path']);
  });
  return path;
}

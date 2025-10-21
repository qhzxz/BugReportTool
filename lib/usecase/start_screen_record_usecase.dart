import 'dart:io';
import 'dart:isolate';

import 'package:bug_report_tool/video/scrcpy_video_recorder.dart';

import '../util/util.dart';

Future<String?> StartScreenRecordUsecase(String serial) async {
  if (Platform.isMacOS || Platform.isWindows) {
    final recorder = await ScrcpyRecorder.getInstance();
    String? path = await recorder.startRecording(serial);
    print('adb 录制视频开始:$path');
    return path;
  } else {
    String time = getCurrentTimeFormatString();
    String path = '/sdcard/video_$time.mp4';
    Isolate.run(() async {
      await runCmd('adb', ['-s', serial, 'shell', 'screenrecord $path']);
    });
    print('adb 录制视频开始:$path');
    return path;
  }
}

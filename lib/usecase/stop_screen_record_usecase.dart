import 'dart:io';

import 'package:bug_report_tool/video/scrcpy_video_recorder.dart';
import 'package:flutter/foundation.dart';

import '../util/util.dart';

Future<bool> StopScreenRecordUsecase(String serial) async {
  {
    if (Platform.isWindows || Platform.isMacOS) {
      final recorder = await ScrcpyRecorder.getInstance();
      final path = await recorder.stopRecording();
      return path != null;
    } else {
      final pidResult = await runCmd('adb', [
        '-s',
        serial,
        'shell',
        'pidof screenrecord',
      ]);
      final pid = pidResult.stdout.toString().trim();
      if (pid.isEmpty) {
        print('未检测到正在运行的 screenrecord 进程。');
        return false;
      }
      print('检测到 screenrecord 进程 ID: $pid');
      // 2. 发送 SIGINT 信号（-2）优雅停止录制
      final killResult = await runCmd('adb', [
        '-s',
        serial,
        'shell',
        'kill -2 $pid',
      ]);
      if (killResult.exitCode == 0) {
        print('已发送 SIGINT，录制已停止。');
      } else {
        stderr.writeln('发送终止信号失败: ${killResult.stderr.toString().trim()}');
      }
      return killResult.exitCode == 0;
    }
  }


}


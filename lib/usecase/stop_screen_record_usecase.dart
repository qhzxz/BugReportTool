import 'dart:io';

import 'package:flutter/foundation.dart';

import '../util/util.dart';

Future<bool> StopScreenRecordUsecase(String serial) async {
  return compute(_StopScreenRecordUsecase, _Param(serial));
}

Future<bool> _StopScreenRecordUsecase(_Param p) async {
  final pidResult = await runCmd('adb', [
    '-s',
    p.serial,
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
    p.serial,
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

class _Param {
  String serial;

  _Param(this.serial);
}

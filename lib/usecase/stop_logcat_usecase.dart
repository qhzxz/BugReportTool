import 'dart:io';

import 'package:flutter/foundation.dart';

import '../util/util.dart';

Future<bool> StopLogcatUsecase(String serial) async {
  return compute(_StopLogcatUsecase, _Param(serial));
}

Future<bool> _StopLogcatUsecase(_Param p) async {
  final pidResult = await runCmd('adb', [
    '-s',
    p.serial,
    'shell',
    'pidof logcat',
  ]);
  final pid = pidResult.stdout.toString().trim();
  if (pid.isEmpty) {
    print('未检测到正在运行的 logcat 进程。');
    return false;
  }
  print('检测到 logcat 进程 ID: $pid');
  final killResult = await runCmd('adb', [
    '-s',
    p.serial,
    'shell',
    'kill -2 $pid',
  ]);
  if (killResult.exitCode == 0) {
    print('已发送 SIGINT，logcat已停止。');
  } else {
    stderr.writeln('发送终止信号失败: ${killResult.stderr.toString().trim()}');
  }
  return killResult.exitCode == 0;
}

class _Param {
  String serial;

  _Param(this.serial);
}

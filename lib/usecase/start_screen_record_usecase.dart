import 'package:flutter/foundation.dart';

import '../util/util.dart';

Future<void> StartScreenRecordUsecase(String serial, String dstPath) async {
  return compute(_StartScreenRecordUsecase, _Param(serial, dstPath));
}

Future<void> _StartScreenRecordUsecase(_Param p) async {
  print('adb 录制视频开始:${p.dstPath}');
  final result = await runCmd(
      'adb', ['-s', p.serial, 'shell', 'screenrecord ${p.dstPath}']);

  print('adb 录制视频结束,${result.exitCode},${result.stderr.toString()}');
}

class _Param {
  String serial;
  String dstPath;

  _Param(this.serial, this.dstPath);
}

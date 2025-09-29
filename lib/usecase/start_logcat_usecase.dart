import 'package:flutter/foundation.dart';

import '../util/util.dart';

Future<void> StartLogcatUsecase(String serial, String dstPath) async {
  return compute(_StartLogcatUsecase, _Param(serial, dstPath));
}

Future<void> _StartLogcatUsecase(_Param p) async {
  print('adb 日志捕捉开始:${p.dstPath}');
  await runCmd('adb', ['-s', p.serial, 'shell', 'logcat -f ${p.dstPath}']);
  print('adb 日志捕捉结束');
}

class _Param {
  String serial;
  String dstPath;

  _Param(this.serial, this.dstPath);
}

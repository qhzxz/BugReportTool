import 'package:flutter/foundation.dart';

import '../util/util.dart';

Future<bool> PullFileUsecase(
  String serial,
  String srcFilePath,
  String dstDirPath,
) async {
  return compute(_PullFileUsecase, _Param(serial, srcFilePath, dstDirPath));
}

Future<bool> _PullFileUsecase(
    _Param p,
    ) async {
  try {
    await runCmd('adb', ['-s', p.serial, 'pull', p.srcFilePath, p.dstDirPath]);
    await runCmd('adb', ['-s', p.serial, 'shell','rm', p.srcFilePath]);
    return true;
  } catch (e) {
    print("拉取文件失败:$e");
  }
  return false;
}


class _Param {
  String serial;
  String srcFilePath;
  String dstDirPath;

  _Param(this.serial, this.srcFilePath, this.dstDirPath);
}
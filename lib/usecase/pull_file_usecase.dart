import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p show basename;

import '../util/util.dart';

Future<File?> PullFileUsecase(
  String serial,
  String srcFilePath,
  String dstDirPath,
) async {
  return compute(_PullFileUsecase, _Param(serial, srcFilePath, dstDirPath));
}

Future<File?> _PullFileUsecase(_Param param) async {
  try {
    await runCmd('adb', [
      '-s',
      param.serial,
      'pull',
      param.srcFilePath,
      param.dstDirPath,
    ]);
    await runCmd('adb', ['-s', param.serial, 'shell', 'rm', param.srcFilePath]);
    ;
    File file = File(
      "${param.dstDirPath}${Platform.pathSeparator}${p.basename(param.srcFilePath)}",
    );
    if (file.existsSync()) {
      print("拉取文件成功");
      return file;
    }
  } catch (e) {
    print("拉取文件异常:$e");
  }
  print("拉取文件失败");
  return null;
}

class _Param {
  String serial;
  String srcFilePath;
  String dstDirPath;

  _Param(this.serial, this.srcFilePath, this.dstDirPath);
}

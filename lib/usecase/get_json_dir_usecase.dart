import 'dart:io';
import 'dart:isolate';

import 'package:bug_report_tool/usecase/get_file_dir_usecase.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;

Future<String?> GetJsonDirUsecase() async {
  final appDir = await GetFileDirUsecase();
  String path = '$appDir${Platform.pathSeparator}json';
  return await Isolate.run(() async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      return null;
    }
    return dir.path;
  });
}

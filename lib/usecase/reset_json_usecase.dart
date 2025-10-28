import 'dart:io';
import 'dart:isolate';

import 'package:bug_report_tool/usecase/get_file_dir_usecase.dart';
import 'package:bug_report_tool/usecase/get_json_dir_usecase.dart';
import 'package:bug_report_tool/usecase/load_config_usecase.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;

Future<void> ResetJsonUsecase() async {
  final jsonDir = await GetJsonDirUsecase();
  if (jsonDir != null) {
    await Isolate.run(() async {
      Directory directory = Directory(jsonDir);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });
  }
}

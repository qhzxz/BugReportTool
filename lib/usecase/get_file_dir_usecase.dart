import 'dart:io';

import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;

Future<String> GetFileDirUsecase() async {
  final base = await getApplicationSupportDirectory();
  final dir = Directory(
    '${base.path}${Platform.pathSeparator}MyApp${Platform.pathSeparator}BugReportTool',
  );
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return dir.path;
}

import 'dart:io';
import 'dart:isolate';

import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;

Future<String> GetFileDirUsecase() async {
  final base = await getApplicationSupportDirectory();
  return await Isolate.run(() async {
    final dir = Directory(
      '${base.path}${Platform.pathSeparator}MyApp${Platform.pathSeparator}BugReportTool',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  });
}

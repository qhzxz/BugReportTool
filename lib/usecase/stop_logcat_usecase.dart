import 'package:bug_report_tool/logcat/logcat.dart';
import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/usecase/usecase.dart';

class StopLogcatUsecase extends UseCase<String> {
  @override
  Future<Result<String>> run() async {
    final instance = await Logcat.getInstance();
    String? path = await instance.stopCapturing();
    if (path != null) {
      return Success(path);
    }
    return Error(exception: 'no log file');
  }
}

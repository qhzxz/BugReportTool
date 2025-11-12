import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:bug_report_tool/video/scrcpy_video_recorder.dart';

import '../util/util.dart';

class StartScreenRecordUsecase extends UseCase<bool> {
  String _serial;

  StartScreenRecordUsecase(this._serial);

  @override
  Future<Result<bool>> run() async {
    final recorder = await ScrcpyRecorder.getInstance();
    String? path = await recorder.startRecording(_serial);
    logInfo('adb 录制视频开始:$path');
    return Success(path != null);
  }
}

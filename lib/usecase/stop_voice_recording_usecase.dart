import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:bug_report_tool/voice/voice_recorder.dart';

class StopVoiceRecordingUsecase extends UseCase<String> {
  @override
  Future<Result<String>> run() async {
    String? path = await VoiceRecorder().stopRecording();
    if (path != null) {
      return Success(path);
    }
    return Error(exception: 'no audio file');
  }
}

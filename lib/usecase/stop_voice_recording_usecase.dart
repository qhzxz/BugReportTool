import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:bug_report_tool/voice/voice_recorder.dart';

class StopVoiceRecordingUsecase extends UseCase<String?> {
  @override
  Future<String?> execute() async {
    return await VoiceRecorder().stopRecording();
  }
}
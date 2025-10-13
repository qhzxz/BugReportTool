import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:bug_report_tool/voice/voice_recorder.dart';

class StartVoiceRecordingUsecasse extends UseCase<bool> {
  @override
  Future<bool> execute() async {
    await VoiceRecorder().startRecording();
    return true;
  }
}
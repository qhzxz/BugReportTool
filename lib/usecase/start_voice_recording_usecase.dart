import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:bug_report_tool/voice/voice_recorder.dart';

class StartVoiceRecordingUsecasse extends UseCase<String?> {
  final String _serial;

  StartVoiceRecordingUsecasse(this._serial);
  @override
  Future<String?> execute() async {
    return await VoiceRecorder().startRecording();
  }
}
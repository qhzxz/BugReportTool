import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:bug_report_tool/voice/voice_recorder.dart';

class StartVoiceRecordingUsecasse extends UseCase<bool> {
  final String _serial;

  StartVoiceRecordingUsecasse(this._serial);

  @override
  Future<Result<bool>> run() async {
    return Success(await await VoiceRecorder().startRecording() != null);
  }
}
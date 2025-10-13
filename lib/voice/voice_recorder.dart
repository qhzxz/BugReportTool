
import 'dart:io';

import 'package:bug_report_tool/usecase/get_file_dir_usecase.dart';
import 'package:record/record.dart';

class VoiceRecorder {

  VoiceRecorder._internal();

  static final VoiceRecorder _instance = VoiceRecorder._internal();

  factory VoiceRecorder(){
    return _instance;
  }


  final AudioRecorder _recorder = AudioRecorder();

  Future<void> startRecording() async {
    if (await _recorder.isRecording()) {
      throw Exception('已经开始录音');
    }
    String dirPath = await GetFileDirUsecase();
    await _recorder.start(RecordConfig(encoder: AudioEncoder.wav),
        path: '$dirPath${Platform.pathSeparator}temp_${DateTime
            .now()
            .millisecondsSinceEpoch}.wav');
  }

  Future<String?> stopRecording() async {
    if (await _recorder.isRecording()) {
      return _recorder.stop();
    }
    throw Exception('未进行录音');
  }
}
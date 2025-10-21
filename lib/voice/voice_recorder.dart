
import 'dart:io';

import 'package:bug_report_tool/usecase/get_file_dir_usecase.dart';
import 'package:record/record.dart';

import '../util/util.dart';

class VoiceRecorder {

  VoiceRecorder._internal();

  static final VoiceRecorder _instance = VoiceRecorder._internal();

  factory VoiceRecorder(){
    return _instance;
  }


  final AudioRecorder _recorder = AudioRecorder();

  Future<String?> startRecording() async {
    if (await _recorder.isRecording()) {
      throw Exception('已经开始录音');
    }
    String time = getCurrentTimeFormatString();
    String dirPath = await GetFileDirUsecase();
    var path = '$dirPath${Platform.pathSeparator}temp_$time.wav';
    await _recorder.start(RecordConfig(encoder: AudioEncoder.wav),
        path: path);
    return path;
  }

  Future<String?> stopRecording() async {
    if (await _recorder.isRecording()) {
      return await _recorder.stop();
    }
    throw Exception('未进行录音');
  }
}
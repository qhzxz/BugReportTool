import 'dart:io';

import 'package:bug_report_tool/video/scrcpy_video_recorder.dart';
import 'package:flutter/foundation.dart';

import '../util/util.dart';

Future<String?> StopScreenRecordUsecase(String serial) async {
  {
    final recorder = await ScrcpyRecorder.getInstance();
    final path = await recorder.stopRecording();
    return path;
  }
}

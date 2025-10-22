import 'dart:io';

import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:bug_report_tool/video/scrcpy_video_recorder.dart';
import 'package:flutter/foundation.dart';

import '../util/util.dart';

class StopScreenRecordUsecase extends UseCase<String> {
  StopScreenRecordUsecase();

  @override
  Future<Result<String>> run() async {
    final recorder = await ScrcpyRecorder.getInstance();
    final path = await recorder.stopRecording();
    if (path != null) return Success(path);
    return Error(exception: 'no screen record');
  }
}

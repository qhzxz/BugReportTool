import 'package:bug_report_tool/video/scrcpy_video_recorder.dart';

Future<String?> StartScreenRecordUsecase(String serial) async {
  final recorder = await ScrcpyRecorder.getInstance();
  String? path = await recorder.startRecording(serial);
  print('adb 录制视频开始:$path');
  return path;
}

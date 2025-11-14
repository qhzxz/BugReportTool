import 'dart:io';
import 'dart:isolate';

import 'package:bug_report_tool/ffmpeg/ffmpeg_manager.dart';
import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/usecase/usecase.dart';


class MixVoiceUsecase extends UseCase<String> {
  final String _videoFilePath;
  final String _audioFilePath;

  MixVoiceUsecase(this._videoFilePath, this._audioFilePath);

  @override
  Future<Result<String>> run() async {
    if (!await File(_videoFilePath).exists()) {
      return Error(exception: 'video is null');
    }
    if (!await File(_audioFilePath).exists()) {
      return Error(exception: 'audio is null');
    }
    String? outputPath = await FFmpegManager().mixVideoAudio(
        _videoFilePath, _audioFilePath);
    if (outputPath == null || !await File(outputPath).exists()) {
      return Error(exception: '混音失败');
    }
    String startTimeStamp= _videoFilePath.substring(_videoFilePath.indexOf('_')+1,_videoFilePath.indexOf('.mp4'));
    var fixed = await FFmpegManager().unifyFrame(outputPath);
    var result = await FFmpegManager().addTimeStamp(fixed, startTimeStamp);
    await Isolate.run(() async {
      var videoFile = File(_videoFilePath);
      if (await videoFile.exists()) {
        await videoFile.delete();
      }
      var audioFile = File(_audioFilePath);
      if (await audioFile.exists()) {
        await audioFile.delete();
      }
      var mixedFile = File(outputPath);
      if (await mixedFile.exists()) {
        await mixedFile.delete();
      }
      var fixedFile = File(fixed);
      if (await fixedFile.exists()) {
        await fixedFile.delete();
      }
    });
    return Success(result);
  }
}
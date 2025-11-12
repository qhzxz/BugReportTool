import 'dart:io';
import 'dart:isolate';

import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/usecase/get_file_dir_usecase.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:bug_report_tool/util/util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';


class MixVoiceUsecase extends UseCase<String> {
  final String _videoFilePath;
  final String _audioFilePath;

  MixVoiceUsecase(this._videoFilePath, this._audioFilePath);

  Future<void> _mergeMp4WithWav(Map<String, String> map) async {
    final result = await Process.run(map['executePath']!,
        ['-i', map['mp4Path']!, '-i', map['wavPath']!, '-map', '0:v:0',
          '-map', '1:a:0',
          '-c:v', 'copy',
          '-c:a', 'aac'
          , map['outputPath']!]);
    logInfo("error message:${result.stderr.toString()}");
    logInfo("return code：${result.exitCode}");
  }

  @override
  Future<Result<String>> run() async{
    if (!await File(_videoFilePath).exists()) return Error(exception: 'video is null');
    if (!await File(_audioFilePath).exists()) return Error(exception: 'audio is null');
    String dirPath = await GetFileDirUsecase();
    String time=getCurrentTimeFormatString();
    String outputPath = '$dirPath${Platform.pathSeparator}video_$time.mp4';
    if (Platform.isMacOS) {
      File file = File('$dirPath${Platform.pathSeparator}ffmpeg${Platform.pathSeparator}ffmpeg');
      if (!file.existsSync()) {
        final bytes = await rootBundle.load('assets/ffmpeg/macos/ffmpeg');
        await Isolate.run(() async {
          await file.create(recursive: true);
          await file.writeAsBytes(bytes.buffer.asUint8List());
          await runCmd('chmod', ['+x', file.path]);
        });
      }
      await compute(_mergeMp4WithWav, {
        'executePath': file.path,
        'mp4Path': _videoFilePath,
        'wavPath': _audioFilePath,
        'outputPath': outputPath
      });
    } else if (Platform.isWindows) {
      File file = File('$dirPath${Platform.pathSeparator}ffmpeg${Platform.pathSeparator}ffmpeg.exe');
      if (!file.existsSync()) {
        final bytes = await rootBundle.load('assets/ffmpeg/windows/ffmpeg.exe');
        await Isolate.run(() async {
          await file.create(recursive: true);
          await file.writeAsBytes(bytes.buffer.asUint8List());
        });
      }
      await compute(_mergeMp4WithWav, {
        'executePath': file.path,
        'mp4Path': _videoFilePath,
        'wavPath': _audioFilePath,
        'outputPath': outputPath
      });
    }
    if (!await File(outputPath).exists()) {
      return Error(exception: '混音失败');
    }
    return Success(outputPath);

  }
}
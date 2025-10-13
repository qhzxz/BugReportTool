import 'dart:io';

import 'package:bug_report_tool/usecase/get_file_dir_usecase.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MixVoiceUsecase extends UseCase<String?> {
  final String _videoFilePath;
  final String _audioFilePath;

  MixVoiceUsecase(this._videoFilePath, this._audioFilePath);

  @override
  Future<String?> execute() async {
    if (!await File(_videoFilePath).exists()) return null;
    if (!await File(_audioFilePath).exists()) return null;
    String dirPath = await GetFileDirUsecase();
    String outputPath = '$dirPath${Platform.pathSeparator}video_${DateTime
        .now()
        .millisecondsSinceEpoch}.mp4';
    String path = '';
    if (Platform.isMacOS) {
      final bytes = await rootBundle.load('assets/ffmpeg/macos/ffmpeg');
      File file = File('$dirPath${Platform.pathSeparator}ffmpeg');
      if (!file.existsSync()) {
        await file.writeAsBytes(bytes.buffer.asUint8List());
      }
      await Process.run('chmod', ['+x',file.path]);
      path = file.path;
    } else if (Platform.isWindows) {

    }
    await compute(_mergeMp4WithWav, {
      'executePath':path,
      'mp4Path': _videoFilePath,
      'wavPath': _audioFilePath,
      'outputPath': outputPath
    });
    return outputPath;
  }

  Future<void> _mergeMp4WithWav(Map<String, String> map) async {
    final result = await Process.run(map['executePath']!,
        ['-i', map['mp4Path']!, '-i', map['wavPath']!, '-map', '0:v:0',
          '-map', '1:a:0',
          '-c:v', 'copy',
          '-c:a', 'aac'
          , map['outputPath']!]);
    print("混合结果：${result.stdout.toString()}");
    print("混合结果2：${result.stderr.toString()}");
    print("混合结果3：${result.exitCode}");
  }
}
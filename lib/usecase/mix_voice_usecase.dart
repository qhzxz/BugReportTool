import 'dart:io';

import 'package:bug_report_tool/usecase/get_file_dir_usecase.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
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
    if (Platform.isMacOS) {
      String cmd=['-i',
        '"$_videoFilePath"',
        '-i',
        '"$_audioFilePath"',
        '-map',
        '0:v:0',
        '-map',
        '1:a:0',
        '-c:v',
        'copy',
        '-c:a',
        'aac',
        '"$outputPath"'
      ].join(' ');
      FFmpegSession session = await FFmpegKit.execute(cmd);
      String? output = await session.getOutput();
      ReturnCode? code=await session.getReturnCode();
      print("output:$output");
      print("code:$code");
    } else if (Platform.isWindows) {
      File file = File('$dirPath${Platform.pathSeparator}ffmpeg.exe');
      if (!file.existsSync()) {
        final bytes = await rootBundle.load('assets/ffmpeg/windows/ffmpeg.exe');
        await file.writeAsBytes(bytes.buffer.asUint8List());
      }
      await compute(_mergeMp4WithWav, {
        'executePath':file.path,
        'mp4Path': _videoFilePath,
        'wavPath': _audioFilePath,
        'outputPath': outputPath
      });
    }
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
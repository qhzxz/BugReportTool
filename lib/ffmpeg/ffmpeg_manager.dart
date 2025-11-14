import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../util/util.dart';

class FFmpegManager {
  // Singleton instance
  static final FFmpegManager _instance = FFmpegManager._internal();

  factory FFmpegManager() {
    return _instance;
  }

  FFmpegManager._internal();

  bool _isInitialized = false;

  late String _executePath;

  late String _dirPath;

  // Method to initialize FFmpeg
  Future<void> initialize(String dirPath) async {
    if (!_isInitialized) {
      _dirPath = dirPath;
      if (Platform.isMacOS) {
        File file = File('$dirPath${Platform.pathSeparator}ffmpeg_1.0${Platform
            .pathSeparator}ffmpeg');
        if (!file.existsSync()) {
          final bytes = await rootBundle.load('assets/ffmpeg/macos/ffmpeg');
          await Isolate.run(() async {
            await file.create(recursive: true);
            await file.writeAsBytes(bytes.buffer.asUint8List());
            await runCmd('chmod', ['+x', file.path]);
          });
        }
        _executePath = file.path;
      } else if (Platform.isWindows) {
        File file = File('$dirPath${Platform.pathSeparator}ffmpeg_1.0${Platform
            .pathSeparator}ffmpeg.exe');
        if (!file.existsSync()) {
          final bytes = await rootBundle.load(
              'assets/ffmpeg/windows/ffmpeg.exe');
          await Isolate.run(() async {
            await file.create(recursive: true);
            await file.writeAsBytes(bytes.buffer.asUint8List());
          });
        }
        _executePath = file.path;
      }

      _isInitialized = true;
    }
  }


  Future<String> unifyFrame(String videoPath) async {
    String time = getCurrentTimeFormatString();
    String outputPath = '$_dirPath${Platform.pathSeparator}unifyFramevideo_$time.mp4';
    await compute(_unifyFrameRate, {
      'executePath': _executePath,
      'mp4Path': videoPath,
      'outputPath': outputPath
    });
    return outputPath;
  }

  Future<String> addTimeStamp(String videoPath,String startTimeStamp) async {
    String time=getCurrentTimeFormatString();
    String outputPath = '$_dirPath${Platform.pathSeparator}videoWithTimestamp_$time.mp4';
    await compute(_addTimestampToVideo, {
      'executePath': _executePath,
      'mp4Path': videoPath,
      'startTimeStamp': startTimeStamp,
      'outputPath': outputPath
    });
    return outputPath;
  }

  Future<String?> mixVideoAudio(String videoPath,String audioPath) async {
    String time=getCurrentTimeFormatString();
    String outputPath = '$_dirPath${Platform.pathSeparator}videoFinal_$time.mp4';
    await compute(_mergeMp4WithWav, {
      'executePath': _executePath,
      'mp4Path': videoPath,
      'wavPath': audioPath,
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
    if (result.exitCode !=0) {
      logInfo("_mergeMp4WithWav error message:${result.stderr.toString()}");
      logInfo("_mergeMp4WithWav return code：${result.exitCode}");
    }else {
      logInfo("_mergeMp4WithWav return code：0");
    }
  }

  Future<void> _addTimestampToVideo(Map<String, String> map) async {
    final isWindows = Platform.isWindows;
    final drawtext = isWindows
        ? r'drawtext=text=%{pts\:localtime\:'+map['startTimeStamp']!+r'\:%Y-%m-%d %H\\:%M\\:%S}:x=20:y=20:fontsize=36:fontcolor=white:box=1:boxcolor=0x00000099'
        : r'drawtext=text=%{pts\\:localtime\\:'+map['startTimeStamp']!+r'\\:%Y-%m-%d %H\\\\\\:%M\\\\\\:%S}:x=20:y=20:fontsize=36:fontcolor=white:box=1:boxcolor=0x00000099';

    print('_addTimestampToVideo drawtext:$drawtext');
    final result = await Process.run(map['executePath']!,
        [
          '-i',
          map['mp4Path']!,
          '-vf',
          drawtext,
          '-c:a',
          'copy',
          map['outputPath']!
        ]);
    logInfo("_addTimestampToVideo error message:${result.stderr.toString()}");
    logInfo("_addTimestampToVideo return code：${result.exitCode}");
    // if (result.exitCode !=0) {
    //
    // }else {
    //   logInfo("_addTimestampToVideo return code：0");
    // }

  }


  Future<String> _unifyFrameRate(Map<String, String> map) async {
    return await runCmd(map['executePath']!,
        [
          '-i',
          map['mp4Path']!,
          '-c:v',
          'libx264',
          '-r',
          '30',
          '-c:a',
          'copy',
          map['outputPath']!
        ]).then((result) {
      if (result.exitCode != 0) {
        logInfo("_unifyFrameRate error message:${result.stderr.toString()}");
        logInfo("_unifyFrameRate return code：${result.exitCode}");
      } else {
        logInfo("_unifyFrameRate return code：0");
      }
      return map['outputPath']!;
    });
  }
}
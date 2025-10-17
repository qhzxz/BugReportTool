import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart';

import '../util/util.dart';
import 'get_file_dir_usecase.dart';

Future<String?> StartScreenRecordUsecase(String serial) async {
  return compute(_StartScreenRecordUsecase, serial);
}

Future<String?> _StartScreenRecordUsecase(String serial) async {
  String dirPath = await GetFileDirUsecase();
  String scrcpyDirPath = '$dirPath${Platform.pathSeparator}screenrecord';
  String time = getCurrentTimeFormatString();
  String path;
  if (Platform.isMacOS) {
    final executePath = '$scrcpyDirPath${Platform.pathSeparator}scrcpy';
    final zipPath = 'assets/scrcpy/macos/scrcpy.zip';
    await _unzip(scrcpyDirPath, executePath, zipPath);
    path = '$dirPath${Platform.pathSeparator}video_$time.mp4';
    Isolate.run(() async {
      await runCmd('chmod', ['+x', executePath]);
      await runCmd(executePath, ['--record', path]);
    });
  }
  else if (Platform.isWindows) {
    final executePath = '$scrcpyDirPath${Platform.pathSeparator}scrcpy.exe';
    final zipPath = 'assets/scrcpy/windows/scrcpy.zip';
    await _unzip(scrcpyDirPath, executePath, zipPath);
    path = '$dirPath${Platform.pathSeparator}video_$time.mp4';
    Isolate.run(() async {
      await runCmd(executePath, ['--record', path]);
    });
  } else {
    path = '/sdcard/video_$time.mp4';
    Isolate.run(() async {
      await runCmd('adb', ['-s', serial, 'shell', 'screenrecord $path']);
    });
  }

  print('adb 录制视频开始:$path');

  return path;
}


Future<void> _unzip(String scrcpyDirPath, String executePath,
    String zipPath) async {
  File scrcpyFile = File(executePath);
  if (!await scrcpyFile.exists()) {
    File scrcpyDir = File(scrcpyDirPath);
    if (await scrcpyDir.exists()) {
      await Isolate.run(() {
        scrcpyDir.delete(recursive: true);
      });
    }
    final bytes = await Isolate.run(() {
      rootBundle.load(zipPath);
    });
    final archive = ZipDecoder().decodeBytes(bytes);
    await Isolate.run(() {
      scrcpyDir.create(recursive: true);
    });
    for (var file in archive.files) {
      final filename = file.name;
      final filePath = '$scrcpyDirPath${Platform.pathSeparator}$filename';
      if (file.isFile) {
        final outFile = File(filePath);
        await Isolate.run(() {
          outFile.create(recursive: true);
          outFile.writeAsBytes(file.content as List<int>, flush: true);
        });
        print('✅ Extracted file: $filePath');
      } else {
        await Isolate.run(() {
          Directory(filePath).createSync(recursive: true);
        });
        print('📁 Created directory: $filePath');
      }
    }
  }
}


import 'dart:io';

import 'package:bug_report_tool/usecase/pull_file_usecase.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:bug_report_tool/usecase/zip_file_usecase.dart';

import 'get_file_dir_usecase.dart';
import 'mix_voice_usecase.dart';

class PrepareFileUsecase extends UseCase<String?> {
  final String _serial;
  final String? _videoFilePath;
  final String? _logFilePath;
  final String? _audioFilePath;

  PrepareFileUsecase(
    this._serial,
    this._videoFilePath,
    this._logFilePath,
    this._audioFilePath,
  );

  @override
  Future<String?> execute() async {
    final dir = await GetFileDirUsecase();
    File? videoFile = await PullFileUsecase(_serial, _videoFilePath ?? "", dir);
    File? logFile = await PullFileUsecase(_serial, _logFilePath ?? "", dir);
    String? newVideo = "";
    String? temp = _audioFilePath;
    if (videoFile != null && await videoFile.exists() && temp != null) {
      newVideo = await MixVoiceUsecase(videoFile.path, temp).execute();
    }
    List<String> zipFilePaths = [];
    if (logFile != null && await logFile.exists()) {
      zipFilePaths.add(logFile.path);
    }
    if (newVideo != null) {
      zipFilePaths.add(newVideo);
      videoFile!.deleteSync();
    } else if (videoFile != null) {
      zipFilePaths.add(videoFile.path);
    }
    if (temp != null) {
      File(temp).deleteSync();
    }

    File? zipFile = await ZipFileUsecase(zipFilePaths);
    if (zipFile != null) {
      for (final path in zipFilePaths) {
        final file = File(path);
        if (file.existsSync()) {
          file.deleteSync(recursive: true);
        }
      }
      return zipFile.path;
    }
    return "";
  }
}
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';

import '../util/util.dart';
import 'get_file_dir_usecase.dart';

Future<File?> ZipFileUsecase(List<String> filePaths) async {
  final dir = await GetFileDirUsecase();
  String dstPath =
      '$dir${Platform.pathSeparator}files_${getCurrentTimeFormatString()}.zip';

  return compute(_ZipFileUsecase, _Param(filePaths, dstPath));
}

Future<File?> _ZipFileUsecase(_Param p) async {
  final archive = Archive();

  for (final path in p.filePaths) {
    // 只读不进内存，而是归档时流式处理
    final file = File(path);
    if (!file.existsSync()) {
      print("file:${path} 不存在");
      continue;
    }
    final stat = await file.stat();
    if (stat.type != FileSystemEntityType.file) continue;
    final input = InputFileStream(path);
    try {
      final archiveFile = ArchiveFile.stream(
        file.uri.pathSegments.last, // zip包内的文件名
        stat.size, // 文件大小
        input, // 文件输入流
      );
      archive.addFile(archiveFile);
    } catch (e) {
      print('$e');
    }
  }

  if (archive.isNotEmpty) {
    // 用 OutputFileStream 直接写入磁盘，避免内存浪费
    final outStream = OutputFileStream(p.dstZipPath);
    ZipEncoder().encode(archive, output: outStream);
    await outStream.close();
    archive.files.forEach((element) async {
      await element.close();
    });
    print("压缩文件成功:${archive.files.length}");
    return File(p.dstZipPath);
  }
  print("压缩文件失败");
  return null;
}

class _Param {
  List<String> filePaths;
  String dstZipPath;

  _Param(this.filePaths, this.dstZipPath);
}

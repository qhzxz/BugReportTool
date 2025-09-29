import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';

Future<bool> ZipFileUsecase(List<String> filePaths, String dstZipPath) async {
  return compute(_ZipFileUsecase, _Param(filePaths, dstZipPath));
}

Future<bool> _ZipFileUsecase(_Param p) async {
  final archive = Archive();

  for (final path in p.filePaths) {
    // 只读不进内存，而是归档时流式处理
    final file = File(path);
    final stat = await file.stat();
    if (stat.type != FileSystemEntityType.file) continue;

    final input = InputFileStream(path);
    final archiveFile = ArchiveFile.stream(
      file.uri.pathSegments.last, // zip包内的文件名
      stat.size, // 文件大小
      input, // 文件输入流
    );
    archive.addFile(archiveFile);
  }

  // 用 OutputFileStream 直接写入磁盘，避免内存浪费
  final outStream = OutputFileStream(p.dstZipPath);
  ZipEncoder().encode(archive, output: outStream);
  await outStream.close();
  print("dst zip file:${p.dstZipPath}");
  for (final path in p.filePaths) {
    final file = File(path);
    file.deleteSync(recursive: true);
  }
  return true;
}

class _Param {
  List<String> filePaths;
  String dstZipPath;

  _Param(this.filePaths, this.dstZipPath);
}

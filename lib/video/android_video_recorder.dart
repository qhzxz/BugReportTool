import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import '../util/util.dart';

class AndroidVideoRecorder {
  AndroidVideoRecorder._internal();

  static AndroidVideoRecorder? _instance;

  static Future<AndroidVideoRecorder>? _initializingFuture;

  static Future<AndroidVideoRecorder> getInstance() async {
    // 如果实例已存在，直接返回
    if (_instance != null) return _instance!;

    // 如果有正在初始化的 Future，等待它完成
    if (_initializingFuture != null) return _initializingFuture!;

    // 否则开始初始化
    final completer = Completer<AndroidVideoRecorder>();
    _initializingFuture = completer.future;

    final singleton = AndroidVideoRecorder._internal();

    _instance = singleton;
    completer.complete(_instance!);

    // 清理初始化 Future（只初始化一次）
    _initializingFuture = null;

    return _instance!;
  }


  /// 是否正在录制
  bool isRecording=false;

  String? _currentPath;

  String? _currentDevice;

  Future<String?> startRecording(String serial) async {
    String time = getCurrentTimeFormatString();
    String path = '/sdcard/video_$time.mp4';
    Isolate.run(() async {
      await runCmd('adb', ['-s', serial, 'shell', 'screenrecord $path']);
    });
    logInfo('adb 录制视频开始:$path');
    return path;
  }

  Future<String?> stopRecording() async {
    String? serial = _currentDevice;
    if (serial == null) return null;
    final pidResult = await runCmd('adb', [
      '-s',
      serial,
      'shell',
      'pidof screenrecord',
    ]);
    final pid = pidResult.stdout.toString().trim();
    if (pid.isEmpty) {
      logInfo('未检测到正在运行的 screenrecord 进程。');
      return null;
    }
    logInfo('检测到 screenrecord 进程 ID: $pid');
    // 2. 发送 SIGINT 信号（-2）优雅停止录制
    final killResult = await runCmd('adb', [
      '-s',
      serial,
      'shell',
      'kill -2 $pid',
    ]);
    if (killResult.exitCode == 0) {
      logInfo('已发送 SIGINT，录制已停止。');
    } else {
      stderr.writeln('发送终止信号失败: ${killResult.stderr.toString().trim()}');
    }
    return _currentPath;
  }
}

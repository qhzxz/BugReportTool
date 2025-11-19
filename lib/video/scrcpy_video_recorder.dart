import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:bug_report_tool/ffmpeg/ffmpeg_manager.dart';
import 'package:flutter/services.dart';

import '../util/util.dart';

/// ✅ 线程安全的单例，用于在 macOS 上调用 scrcpy 录屏
class ScrcpyRecorder {
  /// 私有构造函数
  ScrcpyRecorder._internal();

  /// 全局唯一实例（懒加载 + 线程安全）
  static ScrcpyRecorder? _instance;
  static Future<ScrcpyRecorder>? _initializingFuture;
  static late final String _APP_DIR;
  static late final String _executePath;

  static Future<ScrcpyRecorder> getInstance() async {
    // 如果实例已存在，直接返回
    if (_instance != null) return _instance!;

    // 如果有正在初始化的 Future，等待它完成
    if (_initializingFuture != null) return _initializingFuture!;

    // 否则开始初始化
    final completer = Completer<ScrcpyRecorder>();
    _initializingFuture = completer.future;

    final singleton = ScrcpyRecorder._internal();

    _instance = singleton;
    completer.complete(_instance!);

    // 清理初始化 Future（只初始化一次）
    _initializingFuture = null;

    return _instance!;
  }

  static Future<void> init(String appDir) async {
    _APP_DIR = appDir;
    String scrcpyDirPath = '$_APP_DIR${Platform.pathSeparator}screenrecord';
    if (Platform.isMacOS) {
      final zipPath = 'assets/scrcpy/macos/scrcpy.zip';
      _executePath = '$scrcpyDirPath${Platform.pathSeparator}scrcpy';
      await unzip(scrcpyDirPath, _executePath, zipPath);
      await runCmd('chmod', [
        '+x',
        '$scrcpyDirPath${Platform.pathSeparator}scrcpy',
      ]);
      await runCmd('chmod', [
        '+x',
        '$scrcpyDirPath${Platform.pathSeparator}adb',
      ]);
    } else if (Platform.isWindows) {
      _executePath = '$scrcpyDirPath${Platform.pathSeparator}scrcpy.exe';
      final zipPath = 'assets/scrcpy/windows/scrcpy.zip';
      await unzip(scrcpyDirPath, _executePath, zipPath);
    }
    logInfo("ScrcpyRecorder init finished");
  }


  /// 当前 scrcpy 进程
  Process? _process;

  /// 是否正在录制
  bool get isRecording => _process != null;

  String? _currentPath;

  String? _recordStartTime;

  /// 启动录屏
  Future<String?> startRecording(String serial) async {

    // 防止重复启动
    if (_process != null) {
      logInfo('⚠️ scrcpy 正在运行，不能重复启动。');
      return null;
    }

    try {
      var time_result = await runCmd('adb', ['shell', 'date', '+%s']);
      if (time_result.exitCode == 0) {
        String stdout = time_result.stdout.toString().trim();
        _recordStartTime = stdout;
      }
      String outputPath = '$_APP_DIR${Platform.pathSeparator}video_$_recordStartTime.mp4';
      logInfo('🎬 启动 scrcpy 录屏...');
      _process = await Process.start(_executePath, [
        '-s',
        serial,
        '--record',
        outputPath,
      ], runInShell: true);
      _currentPath = outputPath;
      _process?.stdout.transform(utf8.decoder).listen((d) {});
      _process?.stderr.transform(utf8.decoder).listen((d) {});

      // 监听进程结束
      _process!.exitCode.then((code) {
        logInfo('🛑 scrcpy 退出，代码: $code');
        _process = null;
        _currentPath = null;
      });
      return outputPath;
    } catch (e) {
      logInfo('❌ 启动 scrcpy 失败: $e');
      _process = null;
      _currentPath = null;
    }
    return null;
  }

  /// 停止录屏
  Future<String?> stopRecording() async {
    if (_process == null) {
      logInfo('⚠️ 没有正在运行的 scrcpy 进程。');
      return null;
    }
    Process temp = _process!;
    logInfo('🛑 停止 scrcpy 录屏...');
    try {
      String? result = _currentPath;
      if (Platform.isMacOS) {
        bool k = Process.killPid(temp.pid, ProcessSignal.sigint);
        logInfo('🛑 停止 scrcpy 录屏... $k');
        await temp.exitCode;
      } else if (Platform.isWindows) {
        final kill_result = await Process.run('taskkill', [
          '/IM',
          'scrcpy.exe',
        ]);
        logInfo('kill_result:${kill_result.exitCode}}');
      }
      if (result != null && await File(result).exists()) {
        return result;
      }
      return null;
    } catch (e) {
      logInfo('❌ 停止 scrcpy 失败: $e');
      return null;
    }
  }
}

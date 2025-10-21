import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:bug_report_tool/util/util.dart';

class Logcat {
  Logcat._internal();

  static Logcat? _instance;
  static Future<Logcat>? _initializingFuture;
  static late String _APP_DIR;

  /// 当前 scrcpy 进程
  Process? _process;

  /// 是否正在录制
  bool get isRecording => _process != null;

  String? _currentPath;

  static Future<Logcat> getInstance() async {
    // 如果实例已存在，直接返回
    if (_instance != null) return _instance!;

    // 如果有正在初始化的 Future，等待它完成
    if (_initializingFuture != null) return _initializingFuture!;

    // 否则开始初始化
    final completer = Completer<Logcat>();
    _initializingFuture = completer.future;

    final singleton = Logcat._internal();

    _instance = singleton;
    completer.complete(_instance!);

    // 清理初始化 Future（只初始化一次）
    _initializingFuture = null;

    return _instance!;
  }

  static Future<void> init(String dir) async {
    _APP_DIR = dir;
    print("Logcat init finished");
  }

  Future<String?> startCapturing(String serial) async {
    String time = getCurrentTimeFormatString();
    String outputPath = '$_APP_DIR${Platform.pathSeparator}log_$time.txt';
    File logFile = File(outputPath);
    await Isolate.run(() async {
      await logFile.create(recursive: true);
    });
    // 防止重复启动
    if (_process != null) {
      print('⚠️ Logcat 正在运行，不能重复启动。');
      return null;
    }
    ReceivePort receivePort = ReceivePort();
    SendPort mainSendPort = receivePort.sendPort;
    Isolate.spawn(_writeFile, {'port': mainSendPort, 'path': outputPath});
    SendPort workerSendPort = await receivePort.first;
    try {
      print('🎬 启动 Logcat...');
      _process = await Process.start('adb', [
        '-s',
        serial,
        'logcat',
      ], runInShell: true);
      _currentPath = outputPath;
      _process!.stdout.transform(SystemEncoding().decoder).listen((data) {
        workerSendPort.send(data);
      });
      _process!.stderr.transform(SystemEncoding().decoder).listen((data) {
        workerSendPort.send(data);
      });

      // 监听进程结束
      _process!.exitCode.then((code) {
        print('🛑 Logcat 退出，代码: $code');
        workerSendPort.send('bug_report_close');
        _process = null;
        _currentPath = null;
      });
      return outputPath;
    } catch (e) {
      print('❌ 启动 Logcat 失败: $e');
      workerSendPort.send('bug_report_close');
      _process = null;
      _currentPath = null;
    }
  }

  Future<String?> stopCapturing() async {
    if (_process == null) {
      print('⚠️ 没有正在运行的 Logcat 进程。');
      return null;
    }
    Process temp = _process!;
    print('🛑 停止 Logcat 捕获...');
    try {
      String? result = _currentPath;
      await temp.stdin.close();
      temp.kill(ProcessSignal.sigint);
      await temp.exitCode;
      if (result != null && await File(result).exists()) {
        return result;
      }
      return null;
    } catch (e) {
      print('❌ 停止 Logcat 失败: $e');
    }
  }
}

Future<void> _writeFile(Map<String, dynamic> map) async {
  SendPort mainSendPort = map['port'];
  String filePath = map['path'];
  ReceivePort workerReceiverPort = ReceivePort();
  mainSendPort.send(workerReceiverPort.sendPort);
  File file = File(filePath);
  final w = file.openWrite(mode: FileMode.append);
  await for (var message in workerReceiverPort) {
    if (message == 'bug_report_close') {
      break;
    }
    w.writeln(message);
  }
  await w.flush();
  await w.close();
  print("日志文件正常关闭");
}

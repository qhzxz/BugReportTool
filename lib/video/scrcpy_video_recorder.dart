import 'dart:async';
import 'dart:io';

/// ✅ 线程安全的单例，用于在 macOS 上调用 scrcpy 录屏
class ScrcpyRecorder {
  /// 私有构造函数
  ScrcpyRecorder._internal();

  /// 全局唯一实例（懒加载 + 线程安全）
  static final ScrcpyRecorder _instance = ScrcpyRecorder._internal();
  static ScrcpyRecorder get instance => _instance;

  /// 当前 scrcpy 进程
  Process? _process;

  /// 是否正在录制
  bool get isRecording => _process != null;

  /// 启动录屏
  Future<void> startRecording(String outputPath) async {
    // 防止重复启动
    if (_process != null) {
      print('⚠️ scrcpy 正在运行，不能重复启动。');
      return;
    }

    // 检查 scrcpy 是否可用
    final scrcpyExists = await _checkScrcpyAvailable();
    if (!scrcpyExists) {
      print('❌ scrcpy 不存在，请确保已通过 brew 安装并在 PATH 中。');
      return;
    }

    try {
      print('🎬 启动 scrcpy 录屏...');
      _process = await Process.start(
        'scrcpy',
        [
          '--no-display', // 可选: 不显示窗口，仅录制
          '--record', outputPath,
        ],
        runInShell: true,
      );

      // 输出监听（非阻塞）
      _process!.stdout
          .transform(SystemEncoding().decoder)
          .listen((data) => print('📥 [scrcpy]: $data'));
      _process!.stderr
          .transform(SystemEncoding().decoder)
          .listen((data) => print('⚠️ [scrcpy error]: $data'));

      // 监听进程结束
      _process!.exitCode.then((code) {
        print('🛑 scrcpy 退出，代码: $code');
        _process = null;
      });
    } catch (e) {
      print('❌ 启动 scrcpy 失败: $e');
      _process = null;
    }
  }

  /// 停止录屏
  Future<void> stopRecording() async {
    if (_process == null) {
      print('⚠️ 没有正在运行的 scrcpy 进程。');
      return;
    }

    print('🛑 停止 scrcpy 录屏...');
    try {
      _process?.kill(ProcessSignal.sigterm);
      _process = null;
    } catch (e) {
      print('❌ 停止 scrcpy 失败: $e');
    }
  }

  /// 检查 scrcpy 是否可用
  Future<bool> _checkScrcpyAvailable() async {
    try {
      final result = await Process.run('which', ['scrcpy']);
      return result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}


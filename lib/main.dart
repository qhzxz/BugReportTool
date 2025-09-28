import 'dart:io';
import 'package:bug_report_tool/model/app_jira_config.dart';
import 'package:bug_report_tool/view/app_menu.dart';
import 'package:bug_report_tool/view/edit_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p show basename;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:window_size/window_size.dart';
import 'repository/jira_config_repository.dart';
import 'ui_data.dart';

final JiraConfigRepository REPOSITORY = JiraConfigRepository();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    setWindowTitle('BugReportTool');
    setWindowMinSize(const Size(1280, 720));
    setWindowFrame(const Rect.fromLTWH(100, 100, 1280, 720));
  }
  try {
    runApp(const MyApp());
  } catch (e) {
    print("启动异常：$e");
  }
}

Future<Directory> getLogDirectory() async {
  final base = await getApplicationSupportDirectory();
  return Directory(
    '${base.path}${Platform.pathSeparator}MyApp${Platform.pathSeparator}BugReportTool',
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    _listDevices();
    loadDefaultConfig();
  }

  void loadDefaultConfig() async{
    final configs = await REPOSITORY.loadJsonFilesFromAssets();
    setState(() {
      print("loadDefaultConfig");
      data.configs.clear();
      data.configs.addAll(configs);

      data.projects.clear();
      data.projects.addAll(configs.keys.toList());
    });

  }

  Future<ProcessResult?> runCmd(String execute, List<String> arguments) async {
    try {
      return await Process.run(execute, arguments);
    } catch (e) {
      setState(() {
        data.deviceList.clear();
        data.currentDevice = "";
      });
      print("执行[$execute,$arguments]异常:$e");
      return null;
    }
  }

  UIData data = UIData();


  Future<void> zipSingleFile({
    required String filePath,
    required String zipPath,
  }) async {
    // 1. 读取源文件
    final fileBytes = await File(filePath).readAsBytes();

    // 2. 创建 ZIP 存档对象，并添加文件条目
    final archive = Archive()
      ..addFile(
        ArchiveFile(
          // 在压缩包内的文件名，可使用 basename(filePath)
          filePath.split(Platform.pathSeparator).last,
          fileBytes.length,
          fileBytes,
        ),
      );

    // 3. 将存档编码为 ZIP 格式
    final zipData = ZipEncoder().encode(archive);

    // 4. 写入到目标 .zip 文件
    await File(zipPath).writeAsBytes(zipData!);
    print('已生成压缩文件：$zipPath');
  }

  String getCurrentTimestamp() {
    final now = DateTime.now();
    // 使用 intl 包的 DateFormat
    final formatter = DateFormat('yyyyMMDDHHmmss');
    return formatter.format(now);
  }

  Future<void> reportIssue() async {
    await _stopRecord();
    await _stopCapturingLog();
    await _pullToLocal();
    final logFileName = p.basename(data.currentLogFilePath);
    final videoFileName = p.basename(data.currentVideoFilePath);
    final dir = await getLogDirectory();
    zipSingleFile(
      filePath: '${dir.path}${Platform.pathSeparator}$logFileName',
      zipPath: '${dir.path}${Platform.pathSeparator}log.zip',
    );
    zipSingleFile(
      filePath: '${dir.path}${Platform.pathSeparator}$videoFileName',
      zipPath: '${dir.path}${Platform.pathSeparator}video.zip',
    );
  }

  void onClick() {
    if (data.currentDevice.isEmpty) {
      _listDevices();
      return;
    }
    if (data.isCapturing) {
      reportIssue();
    } else {
      data.currentTimeStamp = getCurrentTimestamp();
      _screenRecord();
      _startCapturingLog();
    }
    setState(() {
      data.isCapturing = !data.isCapturing;
    });
  }

  Future<void> _pullToLocal() async {
    final dir = await getLogDirectory();
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    print("PC 目录：${dir.path}");
    print("adb 开始拉取文件");
    await runCmd('adb', [
      '-s',
      data.currentDevice,
      'pull',
      data.currentVideoFilePath,
      '${dir.path}',
    ]);
    await runCmd('adb', [
      '-s',
      data.currentDevice,
      'pull',
      data.currentLogFilePath,
      '${dir.path}',
    ]);
    print("adb 拉取文件结束");
  }

  Future<void> _stopRecord() async {
    final pidResult = await runCmd('adb', [
      '-s',
      data.currentDevice,
      'shell',
      '\"pidof screenrecord\"'
    ]);
    if (pidResult == null) return;
    final pid = pidResult.stdout.toString().trim();
    if (pid.isEmpty) {
      print('未检测到正在运行的 screenrecord 进程。');
      return;
    }
    print('检测到 screenrecord 进程 ID: $pid');
    // 2. 发送 SIGINT 信号（-2）优雅停止录制
    final killResult = await runCmd('adb', [
      '-s',
      data.currentDevice,
      'shell',
      '\"kill -2\ $pid"'
    ]);
    if (killResult == null) return;
    if (killResult.exitCode == 0) {
      print('已发送 SIGINT，录制已停止。');
    } else {
      stderr.writeln('发送终止信号失败: ${killResult.stderr.toString().trim()}');
    }
  }

  void _screenRecord() async {
    print('adb 录制视频开始');
    data.currentVideoFilePath = '/sdcard/video_${data.currentTimeStamp}.mp4';
    final result = runCmd('adb', [
      '-s',
      data.currentDevice,
      'shell',
      '\"screenrecord ${data.currentVideoFilePath}\"',

    ]);
    print('adb 录制视频结束');
  }

  //

  Future<void> _stopCapturingLog() async {
    final pidResult = await runCmd('adb', [
      '-s',
      data.currentDevice,
      'shell',
      '\"pidof logcat\"'
    ]);
    if (pidResult == null) return;
    final pid = pidResult.stdout.toString().trim();
    if (pid.isEmpty) {
      print('未检测到正在运行的 logcat 进程。');
      return;
    }
    print('检测到 logcat 进程 ID: $pid');
    final killResult = await runCmd('adb', [
      '-s',
      data.currentDevice,
      'shell',
      '\"kill -2 $pid\"'
    ]);
    if (killResult == null) return;
    if (killResult.exitCode == 0) {
      print('已发送 SIGINT，logcat已停止。');
    } else {
      stderr.writeln('发送终止信号失败: ${killResult.stderr.toString().trim()}');
    }
  }

  Future<void> _startCapturingLog() async {
    print('adb 日志捕捉开始');
    data.currentLogFilePath = '/sdcard/log_${data.currentTimeStamp}.txt';
    final result = await runCmd('adb', [
      '-s',
      data.currentDevice,
      'shell',
      '\"logcat -f ${data.currentLogFilePath}\"',
    ]);
    print('adb 日志捕捉结束');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(margin: EdgeInsets.only(top: 50)),
          ),
          AppMenu(
            '请选择当前设备:',
            data.deviceList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            data.currentDevice.isEmpty?null:data.currentDevice,
            (String? selected) {
              setState(() {
                if (selected != null) {
                  data.currentDevice = selected;
                } else {
                  data.currentDevice = "";
                }
              });
            },
          ),
          AppMenu(
            '请选择项目:',
            data.projects.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            data.currentProject.isEmpty ? null : data.currentProject,
            (String? selected) {
              setState(() {
                if (selected != null) {
                  data.updateSelectProject(selected);
                }
              });
            },
          ),
          AppMenu(
            '请选择应用:',
            data.currentAppJiraConfigList.map<DropdownMenuItem<String>>((
              AppJiraConfig c,
            ) {
              return DropdownMenuItem<String>(
                value: c.packageName,
                child: Text(c.packageName),
              );
            }).toList(),
            data.currentApp.isEmpty ? null : data.currentApp,
            (String? selected) {
              setState(() {
                if (selected != null) {
                  data.updateSelectApp(selected);
                }
              });
            },
          ),
          EditText('输入Summary:', 1, 1,(text) {
            setState(() {
              data.summary = text;
            });
          }, null),
          EditText('输入Description:', null, 5,(text) {
            setState(() {
              data.description = text;
            });
          }, TextInputType.multiline),
          Container(
            margin: EdgeInsets.only(top: 50),
            child: Align(
              alignment: Alignment.topCenter,
              child: ElevatedButton(
                onPressed: () {
                  onClick();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // 按钮背景色
                  foregroundColor: Colors.white, // 文本颜色
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ), // 内边距
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: data.currentDevice.isEmpty
                    ? const Text('请先选择设备')
                    : (data.isCapturing
                          ? const Text('结束录制')
                          : const Text('开始录制')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _listDevices() async {
    final result = await runCmd('adb', ['devices']);
    if (result == null) return;
    if (result.exitCode != 0) return;
    final output = result.stdout as String;
    final lines = output.trim().split('\n');

    // 第一行通常是 “List of devices attached”，从第二行开始才是设备信息
    final List<String> serials = [];

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final parts = line.split(RegExp(r'\s+'));
      if (parts.isNotEmpty && parts[0] != 'daemon' && parts[0] != 'offline') {
        serials.add(parts[0]);
      }
    }
    setState(() {
      data.deviceList.clear();
      data.deviceList.addAll(serials);
    });
  }
}

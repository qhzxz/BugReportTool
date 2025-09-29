import 'dart:io';

import 'package:bug_report_tool/model/app_jira_config.dart';
import 'package:bug_report_tool/repository/jira_ticket_repository.dart';
import 'package:bug_report_tool/usecase/create_ticket_usecase.dart';
import 'package:bug_report_tool/usecase/derive_fingerprint_usecase.dart';
import 'package:bug_report_tool/usecase/get_file_dir_usecase.dart';
import 'package:bug_report_tool/usecase/list_device_usecase.dart';
import 'package:bug_report_tool/usecase/pull_file_usecase.dart';
import 'package:bug_report_tool/usecase/query_version_usecase.dart';
import 'package:bug_report_tool/usecase/start_logcat_usecase.dart';
import 'package:bug_report_tool/usecase/start_screen_record_usecase.dart';
import 'package:bug_report_tool/usecase/stop_logcat_usecase.dart';
import 'package:bug_report_tool/usecase/stop_screen_record_usecase.dart';
import 'package:bug_report_tool/usecase/zip_file_usecase.dart';
import 'package:bug_report_tool/util/util.dart';
import 'package:bug_report_tool/view/app_menu.dart';
import 'package:bug_report_tool/view/edit_text.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p show basename;
import 'package:window_size/window_size.dart';

import 'repository/jira_config_repository.dart';
import 'view_model.dart';

final JiraConfigRepository REPOSITORY = JiraConfigRepository();
final JiraTicketRepository TICKET_REPOSITORY = JiraTicketRepository();

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

  ViewModel viewModel = ViewModel();
  late Function onError;

  @override
  void initState() {
    super.initState();
    onError = (Exception e){
      setState(() {
        viewModel.reset();
      });
    };
    _listDevices();
    _loadDefaultConfig();
  }

  void _loadDefaultConfig() async{
    final configs = await REPOSITORY.loadJsonFilesFromAssets();
    setState(() {
      print("loadDefaultConfig");
      viewModel.configs.clear();
      viewModel.configs.addAll(configs);

      viewModel.projects.clear();
      viewModel.projects.addAll(configs.keys.toList());
    });

  }

  Future<bool> _prepareIssue(String serial,String srcVideoFilePath,String srcLogFilePath) async {
    await StopScreenRecordUsecase(viewModel.currentDevice);
    await StopLogcatUsecase(viewModel.currentDevice);
    final dir = await GetFileDirUsecase();
    await PullFileUsecase(serial, srcVideoFilePath, dir);
    await PullFileUsecase(serial, srcLogFilePath, dir);
    return true;
  }

  Future<bool> _zipFile(String srcVideoFilePath, String srcLogFilePath) async {
    final logFileName = p.basename(srcLogFilePath);
    final videoFileName = p.basename(srcVideoFilePath);
    final dir = await GetFileDirUsecase();
    await ZipFileUsecase(
        ['$dir${Platform.pathSeparator}$logFileName'],
        '$dir${Platform.pathSeparator}log.zip'
    );
    await ZipFileUsecase(
        ['$dir${Platform.pathSeparator}$videoFileName'],
        '$dir${Platform.pathSeparator}video.zip'
    );
    return true;
  }

  void onClick(BuildContext context) {
    if (viewModel.currentDevice.isEmpty) {
      _listDevices();
      return;
    }
    if (viewModel.isCapturing) {
      _prepareIssue(viewModel.currentDevice, viewModel.currentVideoFilePath,
          viewModel.currentLogFilePath).then((r) =>
      {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('视频录制完成是否上传Bug'),
              actions: [
                TextButton(
                  child: Text('取消'),
                  onPressed: () => {Navigator.of(context).pop()},
                ),
                TextButton(
                  child: Text('确定'),
                  onPressed: ()  {
                    Navigator.of(context).pop();
                    _zipFile(viewModel.currentVideoFilePath, viewModel.currentLogFilePath)
                    .then((r)=>{
                      setState(() {
                        let(viewModel.getParam(), (p)=>CreateTicketUseCase(TICKET_REPOSITORY, p));
                      })
                    });
                  },
                ),
              ],
            );
          },
        )
      });
    } else {
      viewModel.updateLocalFilePath();
      _startCapturing().catchError((e)=>{
        print("_startCapturing :$e")
      });
    }
    setState(() {
      viewModel.isCapturing = !viewModel.isCapturing;
    });
  }

  void _queryVersion(String serial, String selectedPackage,
      List<String> dependencies) {
    List<String> packages = [selectedPackage];
    packages.addAll(dependencies);
    QueryVersionUseCase(serial, packages).catchError((e)=>onError(e)).then((m){
      setState(() {
        viewModel.updateCurrentVersionMap(selectedPackage, m);
      });
    });
  }

  Future<void> _startCapturing() async {
     StartScreenRecordUsecase(viewModel.currentDevice,viewModel.currentVideoFilePath);
     StartLogcatUsecase(viewModel.currentDevice, viewModel.currentLogFilePath);
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
            viewModel.currentDeviceList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            viewModel.currentDevice.isEmpty?null:viewModel.currentDevice,
            (String? selected) {
              setState(() {
                if (selected != null) {
                  viewModel.currentDevice = selected;
                  DeriveFingerprintUsecase(viewModel.currentDevice).catchError((e)=>onError(e)).then((s)=>{
                    setState(() {
                      viewModel.updateCurrentSystemInfo(s);
                    })
                  });
                }
              });
            },
          ),
          AppMenu(
            '请选择项目:',
            viewModel.projects.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            viewModel.currentProject.isEmpty ? null : viewModel.currentProject,
            (String? selected) {
              setState(() {
                if (selected != null) {
                  viewModel.updateSelectProject(selected);
                }
              });
            },
          ),
          AppMenu(
            '请选择应用:',
            viewModel.currentAppJiraConfigList != null ? viewModel
                .currentAppJiraConfigList!.map<DropdownMenuItem<String>>((
                AppJiraConfig c,) {
              return DropdownMenuItem<String>(
                value: c.packageName,
                child: Text(c.packageName),
              );
            }).toList() : [],
            viewModel.currentAppPackage.isEmpty ? null : viewModel.currentAppPackage,
                (String? selectedPackage) {
                  setState(() {
                    if (selectedPackage != null) {
                      viewModel.updateSelectApp(selectedPackage);
                      List<String> dependencies = viewModel.getDependencies(
                          selectedPackage);
                      _queryVersion(viewModel.currentDevice, selectedPackage,
                          dependencies);
                    }
                  });
            },
          ),
          EditText('输入Summary:', 1, 1,(text) {
            setState(() {
              viewModel.summary = text;
            });
          }, null),
          EditText('输入Description:', null, 5,(text) {
            setState(() {
              viewModel.description = text;
            });
          }, TextInputType.multiline),
          Container(
            margin: EdgeInsets.only(top: 50),
            child: Align(
              alignment: Alignment.topCenter,
              child: ElevatedButton(
                onPressed: () {
                  onClick(context);
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
                child: viewModel.currentDevice.isEmpty
                    ? const Text('请先选择设备')
                    : (viewModel.isCapturing
                          ? const Text('结束录制')
                          : const Text('开始录制')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _listDevices() async {
    ListDeviceUseCase().then((value)=>{
      setState(() {
        viewModel.updateCurrentDevice(value);
      })
    }).catchError((e)=>onError(e));
  }
}

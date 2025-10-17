
import 'dart:io';

import 'package:bug_report_tool/repository/jira_config_repository.dart';
import 'package:bug_report_tool/repository/jira_repository.dart';
import 'package:bug_report_tool/repository/jira_rest_repository.dart';
import 'package:bug_report_tool/usecase/create_ticket_usecase.dart';
import 'package:bug_report_tool/usecase/derive_fingerprint_usecase.dart';
import 'package:bug_report_tool/usecase/list_device_usecase.dart';
import 'package:bug_report_tool/usecase/load_config_usecase.dart';
import 'package:bug_report_tool/usecase/mix_voice_usecase.dart';
import 'package:bug_report_tool/usecase/prepare_file_usecase.dart';
import 'package:bug_report_tool/usecase/query_version_usecase.dart';
import 'package:bug_report_tool/usecase/start_logcat_usecase.dart';
import 'package:bug_report_tool/usecase/start_screen_record_usecase.dart';
import 'package:bug_report_tool/usecase/start_voice_recording_usecase.dart';
import 'package:bug_report_tool/usecase/stop_logcat_usecase.dart';
import 'package:bug_report_tool/usecase/stop_screen_record_usecase.dart';
import 'package:bug_report_tool/usecase/stop_voice_recording_usecase.dart';
import 'package:bug_report_tool/util/util.dart';
import 'package:bug_report_tool/widget//app_menu.dart';
import 'package:bug_report_tool/widget/edit_text.dart';
import 'package:bug_report_tool/viewmodel/report_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/app_jira_config.dart';
import '../usecase/get_file_dir_usecase.dart';
import '../usecase/pull_file_usecase.dart';
import '../usecase/zip_file_usecase.dart';

class ReportPage extends StatefulWidget{

  final ReportViewModel viewModel;
  final JiraConfigRepository _jiraConfigRepository;
  final JiraRestRepository _jiraRestRepository;
  final JiraRepository _jiraRepository;

  const ReportPage({super.key, required this.viewModel, required JiraConfigRepository jiraConfigRepository, required JiraRestRepository jiraRestRepository, required JiraRepository jiraRepository}) : _jiraConfigRepository = jiraConfigRepository, _jiraRestRepository = jiraRestRepository, _jiraRepository = jiraRepository;

  @override
  State<StatefulWidget> createState() {
    return _ReportPageState(viewModel, _jiraConfigRepository, _jiraRestRepository, _jiraRepository);
  }

}

class _ReportPageState extends State<ReportPage>{
  final ReportViewModel viewModel;
  final JiraConfigRepository _jiraConfigRepository;
  final JiraRestRepository _jiraRestRepository;
  final JiraRepository _jiraRepository;

  late Function onError;

  _ReportPageState(this.viewModel, this._jiraConfigRepository, this._jiraRestRepository, this._jiraRepository);



  @override
  void initState() {
    super.initState();
    onError = (Exception e) {
      setState(() {
        viewModel.reset();
      });
    };
    _listDevices();
    _loadDefaultConfig();
  }

  void _loadDefaultConfig() {
    LoadConfigUsecase(_jiraConfigRepository).execute().then((r) =>
    {
      setState(() {
        print("loadDefaultConfig");
        viewModel.configs.clear();
        viewModel.configs.addAll(r);
        viewModel.projects.clear();
        viewModel.projects.addAll(r.keys.toList());
      })
    });
  }

  Future<void> _stopCapturing(
) async {
    await StopScreenRecordUsecase(viewModel.currentDevice);
    await StopLogcatUsecase(viewModel.currentDevice);
    await StopVoiceRecordingUsecase().execute();
  }


  void onClick(BuildContext context) {
    if (viewModel.currentDevice.isEmpty) {
      _listDevices();
      return;
    }
    if (viewModel.isCapturing) {
      _stopCapturing().then(
            (r) => {
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
                    onPressed: () {
                      Navigator.of(context).pop();

                      PrepareFileUsecase(viewModel.currentDevice,
                          viewModel.currentVideoFilePath,
                          viewModel.currentLogFilePath,
                          viewModel.currentAudioFilePath).execute().then((
                          s) {
                            setState(() {
                              let(
                                viewModel.getParam(s??""),
                                    (p) =>
                                    CreateTicketUseCase(
                                        _jiraRestRepository, _jiraRepository, p)
                                        .execute(),
                              );
                            });
                      });
                    },
                  ),
                ],
              );
            },
          ),
        },
      );
    } else {
      _startCapturing().then((m){
        viewModel.updateLocalFilePath(videoFilePath: m['videoPath'],audioFilePath: m['audioPath'],logFilePath: m['logPath']);
      }).catchError((e) => {print("_startCapturing :$e")});
    }
    setState(() {
      viewModel.isCapturing = !viewModel.isCapturing;
    });
  }

  void _queryVersion(
      String serial,
      String selectedPackage,
      List<String> dependencies,
      ) {
    List<String> packages = [selectedPackage];
    packages.addAll(dependencies);
    QueryVersionUseCase(serial, packages).catchError((e) => onError(e)).then((
        m,
        ) {
      setState(() {
        viewModel.updateCurrentVersionMap(selectedPackage, m);
      });
    });
  }

  Future<Map<String, String?>> _startCapturing() async {
    final videoPath = await StartScreenRecordUsecase(
      viewModel.currentDevice,
    );
    final logPath = await StartLogcatUsecase(viewModel.currentDevice);
    final audioPath = await StartVoiceRecordingUsecasse(viewModel.currentDevice)
        .execute();
    return {'videoPath': videoPath, 'logPath': logPath,'audioPath':audioPath};
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
            viewModel.currentDeviceList.map<DropdownMenuItem<String>>((
                String value,
                ) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            viewModel.currentDevice.isEmpty ? null : viewModel.currentDevice,
                (String? selected) {
              setState(() {
                if (selected != null) {
                  viewModel.currentDevice = selected;
                  DeriveFingerprintUsecase(viewModel.currentDevice)
                      .catchError((e) => onError(e))
                      .then(
                        (s) => {
                      setState(() {
                        viewModel.updateCurrentSystemInfo(s);
                      }),
                    },
                  );
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
            viewModel.currentAppJiraConfigList != null
                ? viewModel.currentAppJiraConfigList!
                .map<DropdownMenuItem<String>>((AppJiraConfig c) {
              return DropdownMenuItem<String>(
                value: c.packageName,
                child: Text(c.packageName),
              );
            })
                .toList()
                : [],
            viewModel.currentAppPackage.isEmpty
                ? null
                : viewModel.currentAppPackage,
                (String? selectedPackage) {
              setState(() {
                if (selectedPackage != null) {
                  viewModel.updateSelectApp(selectedPackage);
                  List<String> dependencies = viewModel.getDependencies(
                    selectedPackage,
                  );
                  _queryVersion(
                    viewModel.currentDevice,
                    selectedPackage,
                    dependencies,
                  );
                }
              });
            },
          ),
          EditText(hint: '输入Summary:', maxLine: 1, minLine:1 , onChanged: (text) {
            setState(() {
              viewModel.summary = text;
            });
          }, keyboardType: TextInputType.text),
          EditText(hint: '输入Description:',minLine:  5, onChanged: (text) {
            setState(() {
              viewModel.description = text;
            });
          }, keyboardType: TextInputType.multiline),
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
    ListDeviceUseCase()
        .then(
          (value) => {
        setState(() {
          viewModel.updateCurrentDevice(value);
        }),
      },
    )
        .catchError((e) => onError(e));
  }

}

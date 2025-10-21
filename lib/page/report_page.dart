
import 'dart:io';
import 'dart:isolate';

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
import 'package:bug_report_tool/viewmodel/settings_view_model.dart';
import 'package:bug_report_tool/widget//app_menu.dart';
import 'package:bug_report_tool/widget/edit_text.dart';
import 'package:bug_report_tool/viewmodel/report_view_model.dart';
import 'package:bug_report_tool/widget/loading_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/app_jira_config.dart';
import '../usecase/get_file_dir_usecase.dart';
import '../usecase/pull_file_usecase.dart';
import '../usecase/zip_file_usecase.dart';

class ReportPage extends StatefulWidget{

  final ReportViewModel reportViewModel;
  final SettingsViewModel settingViewModel;
  final JiraConfigRepository _jiraConfigRepository;
  final JiraRestRepository _jiraRestRepository;
  final JiraRepository _jiraRepository;


  const ReportPage(
      {super.key, required this.reportViewModel, required this.settingViewModel, required JiraConfigRepository jiraConfigRepository, required JiraRestRepository jiraRestRepository, required JiraRepository jiraRepository})
      : _jiraConfigRepository = jiraConfigRepository,
        _jiraRestRepository = jiraRestRepository,
        _jiraRepository = jiraRepository;

  @override
  State<StatefulWidget> createState() {
    return _ReportPageState(reportViewModel, settingViewModel,_jiraConfigRepository, _jiraRestRepository, _jiraRepository);
  }

}

class _ReportPageState extends State<ReportPage>{
  final ReportViewModel reportViewModel;
  final SettingsViewModel settingsViewModel;
  final JiraConfigRepository _jiraConfigRepository;
  final JiraRestRepository _jiraRestRepository;
  final JiraRepository _jiraRepository;

  late Function onError;

  _ReportPageState(this.reportViewModel, this.settingsViewModel,
      this._jiraConfigRepository, this._jiraRestRepository,
      this._jiraRepository);



  @override
  void initState() {
    super.initState();
    onError = (Exception e) {
      setState(() {
        reportViewModel.reset();
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
        reportViewModel.configs.clear();
        reportViewModel.configs.addAll(r);
        reportViewModel.projects.clear();
        reportViewModel.projects.addAll(r.keys.toList());
      })
    });
  }

  Future<String?> _stopCapturing(
) async {
    String? videoPath = await StopScreenRecordUsecase(reportViewModel.currentDevice);
    String? logPath = await StopLogcatUsecase(reportViewModel.currentDevice);
    String? audioPath = await StopVoiceRecordingUsecase().execute();
    if (videoPath == null) {
      throw Exception('缺少音频');
    }
    if (logPath == null) {
      throw Exception('缺少日志');
    }
    String? newVideo;
    if (audioPath != null) {
      newVideo = await MixVoiceUsecase(videoPath, audioPath).execute();
      File audio = File(audioPath);
      File video = File(videoPath);
      await Isolate.run(() async {
        if (await audio.exists()) {
          await audio.delete();
        }
        if (await video.exists()) {
          await video.delete();
        }
      });
    } else {
      newVideo = videoPath;
    }
    List<String> zipFilePaths = [];
    zipFilePaths.add(logPath);
    if (newVideo != null) {
      zipFilePaths.add(newVideo);
    }
    if (zipFilePaths.isEmpty) {
      throw Exception('无文件');
    }
    File? zipFile = await ZipFileUsecase(zipFilePaths);
    await Isolate.run(()async{
      for (final path in zipFilePaths) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    });
    if (zipFile != null) {
      return zipFile.path;
    }
    return null;
  }


  void onClick(BuildContext context) {
    if (reportViewModel.currentDevice.isEmpty) {
      _listDevices();
      return;
    }
    if (reportViewModel.isCapturing) {
      showDialog(context: context,
          builder: (context) => LoadingDialog(text: '正在压缩文件...'),
          barrierDismissible: false);
      _stopCapturing().then(
            (r) {
          setState(() {
            reportViewModel.isCapturing = false;
          });
          Navigator.of(context).pop();
          if (r != null) {
            reportViewModel.updateZipFilePath(r);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return _showConfirmDialog(context);
              },
            );
          }
        },
      ).onError((e, s) {
        Navigator.of(context).pop();
        _listDevices();
        setState(() {
          reportViewModel.isCapturing = false;
        });
        print("_stopCapturing :$e");
      });
    } else {
      showDialog(context: context,
          builder: (context) => LoadingDialog(text: '启动录制...'),
          barrierDismissible: false);
      _startCapturing().then((r) {
        Navigator.of(context).pop();
        setState(() {
          reportViewModel.isCapturing = true;
        });
      }).catchError((e) {
        Navigator.of(context).pop();
        _listDevices();
        setState(() {
          reportViewModel.isCapturing = false;
        });
        print("_startCapturing :$e");
      });
    }
  }

  Widget _showConfirmDialog(BuildContext context){
    return AlertDialog(
      insetPadding: EdgeInsets.only(left: 50,right: 50,top: 30,bottom: 30),
      title: Text('视频录制完成是否上传Bug'),
      actions: [
        TextButton(
          child: Text('取消'),
          onPressed: (){
            _deleteFile();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('确定'),
          onPressed: () {
            Navigator.of(context).pop();
            // _reportIssue(context);
          },
        ),
      ],
    );
  }

  void _deleteFile() async {
    File zip = File(reportViewModel.currentZipFilePath);
    await Isolate.run(() async {
      if (await zip.exists()) {
        await zip.delete();
      }
    });
  }

  void _reportIssue(BuildContext context) async {
    showDialog(context: context,
        builder: (context) => LoadingDialog(text: '正在上报BUG...'));
    let(
      reportViewModel.getParam(),
          (p) =>
          CreateTicketUseCase(
              _jiraRestRepository, _jiraRepository, p)
              .execute().then((r) {
            Navigator.of(context).pop();
          }).onError((e, s) {
            Navigator.of(context).pop();
          }),
    );
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
        reportViewModel.updateCurrentVersionMap(selectedPackage, m);
      });
    });
  }

  Future<bool> _startCapturing() async {
    await StartScreenRecordUsecase(reportViewModel.currentDevice);
    await StartLogcatUsecase(reportViewModel.currentDevice);
    await StartVoiceRecordingUsecasse(reportViewModel.currentDevice)
        .execute();
    return true;
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
            reportViewModel.currentDeviceList.map<DropdownMenuItem<String>>((
                String value,
                ) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            reportViewModel.currentDevice.isEmpty ? null : reportViewModel.currentDevice,
                (String? selected) {
              setState(() {
                if (selected != null) {
                  reportViewModel.currentDevice = selected;
                  DeriveFingerprintUsecase(reportViewModel.currentDevice)
                      .catchError((e) => onError(e))
                      .then(
                        (s) => {
                      setState(() {
                        reportViewModel.updateCurrentSystemInfo(s);
                      }),
                    },
                  );
                }
              });
            },
          ),
          AppMenu(
            '请选择项目:',
            reportViewModel.projects.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            reportViewModel.currentProject.isEmpty ? null : reportViewModel.currentProject,
                (String? selected) {
              setState(() {
                if (selected != null) {
                  reportViewModel.updateSelectProject(selected);
                }
              });
            },
          ),
          AppMenu(
            '请选择应用:',
            reportViewModel.currentAppJiraConfigList != null
                ? reportViewModel.currentAppJiraConfigList!
                .map<DropdownMenuItem<String>>((AppJiraConfig c) {
              return DropdownMenuItem<String>(
                value: c.packageName,
                child: Text(c.packageName),
              );
            })
                .toList()
                : [],
            reportViewModel.currentAppPackage.isEmpty
                ? null
                : reportViewModel.currentAppPackage,
                (String? selectedPackage) {
              setState(() {
                if (selectedPackage != null) {
                  reportViewModel.updateSelectApp(selectedPackage);
                  List<String> dependencies = reportViewModel.getDependencies(
                    selectedPackage,
                  );
                  _queryVersion(
                    reportViewModel.currentDevice,
                    selectedPackage,
                    dependencies,
                  );
                }
              });
            },
          ),
          EditText(hint: '输入Summary:', maxLine: 1, minLine:1 , onChanged: (text) {
            setState(() {
              reportViewModel.summary = text;
            });
          }, keyboardType: TextInputType.text),
          EditText(hint: '输入Description:',minLine:  5, onChanged: (text) {
            setState(() {
              reportViewModel.description = text;
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
                child: reportViewModel.currentDevice.isEmpty
                    ? const Text('请先选择设备')
                    : (reportViewModel.isCapturing
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
          (value) =>
      {
        setState(() {
          reportViewModel.updateDeviceList(value);
        }),
      },
    )
        .catchError((e) {
      setState(() {
        reportViewModel.updateDeviceList([]);
      });
    });
  }

}

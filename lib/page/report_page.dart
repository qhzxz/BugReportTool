
import 'dart:io';
import 'dart:isolate';

import 'package:bug_report_tool/main.dart';
import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/model/ticket.dart';
import 'package:bug_report_tool/repository/jira_config_repository.dart';
import 'package:bug_report_tool/repository/jira_repository.dart';
import 'package:bug_report_tool/repository/jira_rest_repository.dart';
import 'package:bug_report_tool/usecase/create_ticket_usecase.dart';
import 'package:bug_report_tool/usecase/derive_fingerprint_usecase.dart';
import 'package:bug_report_tool/usecase/list_device_usecase.dart';
import 'package:bug_report_tool/usecase/load_config_usecase.dart';
import 'package:bug_report_tool/usecase/mix_voice_usecase.dart';
import 'package:bug_report_tool/usecase/query_version_usecase.dart';
import 'package:bug_report_tool/usecase/start_logcat_usecase.dart';
import 'package:bug_report_tool/usecase/start_screen_record_usecase.dart';
import 'package:bug_report_tool/usecase/start_voice_recording_usecase.dart';
import 'package:bug_report_tool/usecase/stop_logcat_usecase.dart';
import 'package:bug_report_tool/usecase/stop_screen_record_usecase.dart';
import 'package:bug_report_tool/usecase/stop_voice_recording_usecase.dart';
import 'package:bug_report_tool/util/util.dart';
import 'package:bug_report_tool/viewmodel/report_view_model.dart';
import 'package:bug_report_tool/viewmodel/settings_view_model.dart';
import 'package:bug_report_tool/widget//app_menu.dart';
import 'package:bug_report_tool/widget/edit_text.dart';
import 'package:bug_report_tool/widget/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/app_jira_config.dart';
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
    return ReportPageState(reportViewModel, settingViewModel,_jiraConfigRepository, _jiraRestRepository, _jiraRepository);
  }

}

class ReportPageState extends TabPageState<ReportPage>{
  final ReportViewModel reportViewModel;
  final SettingsViewModel settingsViewModel;
  final JiraConfigRepository _jiraConfigRepository;
  final JiraRestRepository _jiraRestRepository;
  final JiraRepository _jiraRepository;

  late Function onError;

  ReportPageState(this.reportViewModel, this.settingsViewModel,
      this._jiraConfigRepository, this._jiraRestRepository,
      this._jiraRepository);


  @override
  void onTabSelect() {

  }

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
    LoadConfigUsecase(_jiraConfigRepository).execute().then((r)
    {
      if(r is Success){
        Map<String, List<AppJiraConfig>> map = (r as Success).result;
        setState(() {
          print("loadDefaultConfig");
          reportViewModel.configs.clear();
          reportViewModel.configs.addAll(map);
          reportViewModel.projects.clear();
          reportViewModel.projects.addAll(map.keys.toList());
        });
      }

    });
  }

  Future<String?> _stopCapturing(
) async {
    var futureVideo = StopScreenRecordUsecase().execute();
    var futureLog = StopLogcatUsecase().execute();
    var futureAudio;
    if (settingsViewModel.setting.enableVoiceRecording) {
      futureAudio = StopVoiceRecordingUsecase().execute();
    }
    Result<String> videoResult = await futureVideo;
    Result<String> logResult = await futureLog;
    Result<String> audioResult;
    if (futureAudio != null) {
      audioResult = await futureAudio;
    } else {
      audioResult = Error(exception: 'audio recording is disable');
    }

    if (videoResult is Error) {
      throw Exception('缺少视频');
    }
    if (logResult is Error) {
      throw Exception('缺少日志');
    }
    Result<String> newVideo;
    if (audioResult is Success) {
      var audioPath = (audioResult as Success<String>).result;
      var videoPath = (videoResult as Success<String>).result;
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
      newVideo = videoResult;
    }
    List<String> zipFilePaths = [];
    zipFilePaths.add((logResult as Success<String>).result);
    if (newVideo is Success) {
      zipFilePaths.add((newVideo as Success<String>).result);
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


  void onClick() {
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
                return _showConfirmDialog();
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
        if (r) {
          setState(() {
            reportViewModel.isCapturing = true;
          });
        }else{
          _listDevices();
        }
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

  Widget _showConfirmDialog(){
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
            _reportIssue();
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

  void _reportIssue() async {
    showDialog(context: context,
        barrierDismissible: false,
        builder: (context) => LoadingDialog(text: '正在上报BUG...'));
    let(
        reportViewModel.getParam(settingsViewModel.setting.reporterEmail),
            (p) {
          CreateTicketUseCase(
              _jiraRestRepository, _jiraRepository, p)
              .execute().then((r) {
            Navigator.of(context).pop();
            if (r is Success<Ticket>) {
              showDialog(context: context, builder: (context) =>
                  AlertDialog(
                    title: Text("创建${r.result.ticketId}成功  🎉"), actions: [
                    TextButton(onPressed: () {
                      final Uri url = Uri.parse('https://jira.telenav.com:8443/browse/${r.result.ticketId}');
                      launchUrl(url);
                      Navigator.of(context).pop();
                    }, child: Text('确定'))
                  ]));
            }else {
              showDialog(context: context, builder: (context) =>
                  AlertDialog(
                      title: Text('创建失败，请在历史记录页面重试'),
                      content:Text('${(r as Error).exception?.toString()}'),actions: [
                    TextButton(onPressed: () {
                      Navigator.of(context).pop();
                    }, child: Text('确定'))
                  ]));
            }
          }).onError((e, s) {
            Navigator.of(context).pop();
            showDialog(context: context, builder: (context) =>
                AlertDialog(
                    title: Text('创建失败，请在历史记录页面重试'), actions: [
                  TextButton(onPressed: () {
                    Navigator.of(context).pop();
                  }, child: Text('确定'))
                ]));
          });
        }
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
    var futureVideo = StartScreenRecordUsecase(
        reportViewModel.currentDevice).execute();
    var futureLog = StartLogcatUsecase(
        reportViewModel.currentDevice).execute();
    var futureAudio;
    if (settingsViewModel.setting.enableVoiceRecording) {
      futureAudio = StartVoiceRecordingUsecasse(
          reportViewModel.currentDevice).execute();
    }
    Result videoResult = await futureVideo;
    Result logResult = await futureLog;
    if (futureAudio != null) {
      Result audioResult = await futureAudio;
      if ((audioResult is Success<bool> && !audioResult.result) ||
          audioResult is Error) {
        return false;
      }
    }
    if ((videoResult is Success<bool> && !videoResult.result) ||
        videoResult is Error) {
      return false;
    }
    if ((logResult is Success<bool> && !logResult.result) ||
        logResult is Error) {
      return false;
    }

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

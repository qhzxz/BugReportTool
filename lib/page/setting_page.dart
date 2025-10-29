import 'dart:io';

import 'package:bug_report_tool/main.dart';
import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/model/setting.dart';
import 'package:bug_report_tool/usecase/get_json_dir_usecase.dart';
import 'package:bug_report_tool/usecase/get_setting_usecase.dart';
import 'package:bug_report_tool/usecase/reset_json_usecase.dart';
import 'package:bug_report_tool/usecase/save_setting_usecase.dart';
import 'package:bug_report_tool/util/util.dart';
import 'package:bug_report_tool/widget/edit_text.dart';
import 'package:bug_report_tool/viewmodel/settings_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widget/switch.dart';

class SettingsPage extends StatefulWidget {
  final SettingsViewModel viewModel;

  const SettingsPage({super.key, required this.viewModel});

  @override
  State<StatefulWidget> createState() {
    return SettingsPageState(viewModel);
  }
}

class SettingsPageState extends TabPageState<SettingsPage> {
  final SettingsViewModel viewModel;

  SettingsPageState(this.viewModel);

  @override
  void initState() {
    super.initState();
    GetSettingUsecase().execute().then((s) {
      if (s is Success) {
        setState(() {
          viewModel.updateSetting((s as Success<Setting>).result);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('email build:${viewModel.setting.reporterEmail}');
    return Scaffold(
      body: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(margin: EdgeInsets.only(top: 50)),
          ),
          SwitchBox(
            hint: '启动录音',
            isOpen: viewModel.setting.enableVoiceRecording,
            onChanged: (e) {
              var copy = viewModel.setting.copy(
                enable: !viewModel.setting.enableVoiceRecording,
              );
              SaveSettingUsecase(copy).execute().then((r) {
                if (r is Success && (r as Success<bool>).result) {
                  setState(() {
                    viewModel.updateSetting(copy);
                  });
                }
              });
            },
          ),
          SizedBox(width: 25, height: 25),
          Container(alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 50), child: ElevatedButton(
                onPressed: () {
                  GetJsonDirUsecase().then((s) {
                    if (s != null) {
                      openDirectory(s);
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  // 背景色
                  foregroundColor: Colors.white,
                  // 字体颜色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // 圆角半径
                  ),
                  elevation: 4,
                  // 阴影
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ), // 内边距
                ),
                child: Text('打开本地JSON文件目录'),
              )),
          SizedBox(width: 25, height: 25),
          Container(alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 50),
              child: ElevatedButton(
                onPressed: () {
                  ResetJsonUsecase().then((s) {
                    showDialog(context: context, builder: (context) =>
                        AlertDialog(title: Text('已重置，现在需要重新启动应用'),
                            actions: [TextButton(onPressed: () {
                              exit(0);
                            }, child: Text(
                                '确定'))
                            ]));
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  // 背景色
                  foregroundColor: Colors.white,
                  // 字体颜色
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // 圆角半径
                  ),
                  elevation: 4,
                  // 阴影
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ), // 内边距
                ),
                child: Text('恢复默认JSON文件'),
              )
          ),
        ],
      ),
    );
  }

  Future<void> openDirectory(String path) async {
    if (Platform.isWindows) {
      await runCmd('explorer', [path]);
    } else if (Platform.isMacOS) {
      await runCmd('open', [path]);
    } else if (Platform.isLinux) {
      await runCmd('xdg-open', [path]);
    }
  }

  @override
  void onTabSelect() {
    GetSettingUsecase().execute().then((s) {
      if (s is Success) {
        setState(() {
          viewModel.updateSetting((s as Success<Setting>).result);
        });
      }
    });
  }
}

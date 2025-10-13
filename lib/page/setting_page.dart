import 'package:bug_report_tool/model/setting.dart';
import 'package:bug_report_tool/usecase/get_setting_usecase.dart';
import 'package:bug_report_tool/usecase/save_setting_usecase.dart';
import 'package:bug_report_tool/view/edit_text.dart';
import 'package:bug_report_tool/viewmodel/settings_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../view/switch.dart';

class SettingsPage extends StatefulWidget {
  final SettingsViewModel viewModel;

  const SettingsPage({super.key, required this.viewModel});

  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState(viewModel);
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsViewModel viewModel;

  _SettingsPageState(this.viewModel);

  @override
  void initState() {
    GetSettingUsecase().execute().then((s) {
      setState(() {
        viewModel.updateSetting(s);
      });
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
                if (r) {
                  setState(() {
                    viewModel.updateSetting(copy);
                  });
                }
              });
            },
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              EditText(
                hint: "报告人邮箱:",
                maxLine: 1,
                minLine: 1,
                onChanged: (text) {
                  viewModel.updateTempEmail(text);
                },
                defaultValue: viewModel.setting.reporterEmail,
                keyboardType: TextInputType.emailAddress,
              ), SizedBox(width: 25),
              ElevatedButton(
                onPressed: () {
                  Setting s = viewModel.setting.copy(
                      email: viewModel.tempEmail);
                  SaveSettingUsecase(s).execute().then((r) {
                    if (r) {
                      setState(() {
                        viewModel.updateSetting(s);
                      });
                    }
                  });
                },
                child: Text("保存"),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

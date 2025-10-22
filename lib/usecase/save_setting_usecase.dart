import 'dart:convert';
import 'dart:isolate';

import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/model/setting.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:bug_report_tool/util/constatnts.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveSettingUsecase extends UseCase<bool> {
  final Setting _settings;

  SaveSettingUsecase(this._settings);

  @override
  Future<Result<bool>> run() async {
    String json = jsonEncode(_settings.toJson());
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return Success(await preferences.setString(Constants.SETTING_KEY, json));
  }
}

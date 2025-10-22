import 'dart:convert';

import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/model/setting.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:bug_report_tool/util/constatnts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetSettingUsecase extends UseCase<Setting> {
  @override
  Future<Result<Setting>> run() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? json = await preferences.getString(Constants.SETTING_KEY);
    if (json != null) {
      Map<String, dynamic> result = jsonDecode(json);
      return Success(Setting.fromJson(result));
    }
    return Success(Setting());
  }
}

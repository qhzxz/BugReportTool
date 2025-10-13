import 'package:bug_report_tool/model/setting.dart';

class SettingsViewModel {
  String _tempEmail = "";

  Setting _setting = Setting();

  Setting get setting => _setting;

  String get tempEmail => _tempEmail;

  updateTempEmail(String text) {
    _tempEmail = text;
  }

  updateSetting(Setting setting) {
    this._setting = setting;
  }
}

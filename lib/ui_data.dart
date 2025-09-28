
import 'package:bug_report_tool/model/app_jira_config.dart';

class UIData {
  List<String> deviceList = [];
  List<AppJiraConfig> currentAppJiraConfigList = [];
  List<String> appList = [];
  List<String> projects = [];
  Map<String,List<AppJiraConfig>> configs= {};
  String currentDevice = "";
  String currentProject = "";
  String currentApp = "";
  String currentTimeStamp = "";
  String currentVideoFilePath = "";
  String currentLogFilePath = "";
  String summary = "";
  String description = "";
  bool isCapturing = false;

  void updateSelectProject(String selected) {
    var list = configs[selected];
    if (list != null) {
      currentAppJiraConfigList = list;
    }
    currentProject = selected;
    currentApp = "";
  }

  void updateSelectApp(String selected) {
    currentApp = selected;
  }
}
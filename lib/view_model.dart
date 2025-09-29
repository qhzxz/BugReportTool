
import 'package:bug_report_tool/model/app_jira_config.dart';
import 'package:bug_report_tool/usecase/create_ticket_usecase.dart';
import 'package:intl/intl.dart';

class ViewModel {
  final List<String> appList = [];
  final List<String> projects = [];
  final Map<String, List<AppJiraConfig>> configs = {};

  List<String> _currentDeviceList = [];
  List<AppJiraConfig>? _currentAppJiraConfigList;
  Map<String, String> _currentVersionMap = {};
  String _currentSystemInfo = "";
  String _currentDevice = "";

  List<String> get currentDeviceList => _currentDeviceList;
  String _currentProject = "";
  String _currentAppPackage = "";
  String _currentTimeStamp = "";
  String _currentVideoFilePath = "";
  String _currentLogFilePath = "";

  String summary = "";
  String description = "";
  bool isCapturing = false;

  void updateCurrentSystemInfo(String info) {
    _currentSystemInfo = info;
  }

  void updateSelectProject(String selectedProject) {
    var list = configs[selectedProject];
    if (list != null) {
      _currentAppJiraConfigList = list;
    }
    _currentProject = selectedProject;
    _currentAppPackage = "";
  }

  void updateSelectApp(String selectedApp) {
    _currentAppPackage = selectedApp;
  }

  void reset() {
    _currentDeviceList = [];
    _currentVersionMap = {};
    _currentAppJiraConfigList = null;
    _currentDevice = "";
    _currentProject = "";
    _currentAppPackage = "";
    _currentTimeStamp = "";
    _currentVideoFilePath = "";
    _currentLogFilePath = "";
  }

  void updateCurrentVersionMap(String package, Map<String, String> map) {
    if (_currentAppPackage != package) {
      return;
    }
    _currentVersionMap.clear();
    _currentVersionMap.addAll(map);
  }

  List<String> getDependencies(String selectedApp) {
    final currentAppJiraConfigList = _currentAppJiraConfigList;
    if (currentAppJiraConfigList != null) {
      int index = currentAppJiraConfigList.indexWhere((e) =>
      e.packageName == selectedApp);
      if (index != -1) {
        List<String>? result = currentAppJiraConfigList[index].dependPackages;
        if (result != null) {
          return result;
        }
      }
    }
    return [];
  }

  String getCurrentTimestamp() {
    final now = DateTime.now();
    // 使用 intl 包的 DateFormat
    final formatter = DateFormat('yyyyMMDDHHmmss');
    return formatter.format(now);
  }


  void updateLocalFilePath() {
    _currentTimeStamp = getCurrentTimestamp();
    _currentVideoFilePath = '/sdcard/video_$_currentTimeStamp.mp4';
    _currentLogFilePath = '/sdcard/log_$_currentTimeStamp.txt';
  }

  CreateTicketParam? getParam() {
    final currentAppJiraConfigList = _currentAppJiraConfigList;
    if (currentAppJiraConfigList == null) return null;
    if (_currentAppPackage.isEmpty) return null;
    int index = currentAppJiraConfigList.indexWhere((e) =>
    e.packageName == _currentAppPackage);
    if (index == -1) return null;
    Map<String, String> environment = {};
    environment.addAll(_currentVersionMap);
    environment['system_info:'] = _currentSystemInfo;
    print("currentVersionMap:$_currentVersionMap");

    return CreateTicketParam(
        currentAppJiraConfigList[index], summary, description, "", environment);
  }

  void updateCurrentDevice(List<String> list) {
    _currentDeviceList.clear();
    _currentDeviceList.addAll(list);
  }

  List<AppJiraConfig>? get currentAppJiraConfigList =>
      _currentAppJiraConfigList;

  Map<String, String> get currentVersionMap => _currentVersionMap;

  String get currentSystemInfo => _currentSystemInfo;

  String get currentDevice => _currentDevice;

  String get currentProject => _currentProject;

  String get currentAppPackage => _currentAppPackage;

  String get currentTimeStamp => _currentTimeStamp;

  String get currentVideoFilePath => _currentVideoFilePath;

  String get currentLogFilePath => _currentLogFilePath;

  set currentDevice(String value) {
    _currentDevice = value;
  }


}
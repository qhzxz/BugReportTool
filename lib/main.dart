import 'dart:io';

import 'package:bug_report_tool/database/app_database.dart';
import 'package:bug_report_tool/database/dao/ticket_dao.dart';
import 'package:bug_report_tool/logcat/logcat.dart';
import 'package:bug_report_tool/page/history_page.dart';
import 'package:bug_report_tool/page/report_page.dart';
import 'package:bug_report_tool/page/setting_page.dart';
import 'package:bug_report_tool/repository/jira_repository.dart';
import 'package:bug_report_tool/repository/jira_rest_repository.dart';
import 'package:bug_report_tool/usecase/get_file_dir_usecase.dart';
import 'package:bug_report_tool/util/logger.dart';
import 'package:bug_report_tool/util/util.dart';
import 'package:bug_report_tool/video/scrcpy_video_recorder.dart';
import 'package:bug_report_tool/viewmodel/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:window_size/window_size.dart';

import 'repository/jira_config_repository.dart';
import 'viewmodel/report_view_model.dart';



final JiraConfigRepository JIRA_CONFIG_REPOSITORY = JiraConfigRepository();
final JiraRestRepository JIRA_REST_REPOSITORY = JiraRestRepository();
late final JiraRepository JIRA_REPOSITORY;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'bug_report_tool.sqlite'));

  await GetFileDirUsecase().then((d) async {
     BugReportLogger.init(d);
    await ScrcpyRecorder.init(d);
    await Logcat.init(d);
   
  });
  logInfo("db file:${file.path}");
  JIRA_REPOSITORY = JiraRepository(TicketDao(AppDatabase(file)));
  logInfo("初始化完成");
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    setWindowTitle('BugReportTool');
    setWindowMinSize(const Size(1280, 720));
    setWindowFrame(const Rect.fromLTWH(100, 100, 1280, 720));
  }
  logInfo("设置大小完成");
  try {
    runApp(const MyApp());
  } catch (e) {
    logInfo("启动异常：$e");
  }
  logInfo("启动完成");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ReportViewModel reportViewModel = ReportViewModel();
  SettingsViewModel settingsViewModel = SettingsViewModel();
  final List<String> menus = ['上报BUG', '历史记录','设置'];
  GlobalKey<ReportPageState> reportKey = GlobalKey();
  GlobalKey<HistoryPageState> historyKey = GlobalKey();
  GlobalKey<SettingsPageState> settingKey = GlobalKey();
  late final List<GlobalKey<TabPageState>> keyList;
  late final List<Widget> pages;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    keyList = [reportKey, historyKey,settingKey];
    pages = [
      ReportPage(key: reportKey,reportViewModel: reportViewModel,
          settingViewModel: settingsViewModel,
          jiraConfigRepository: JIRA_CONFIG_REPOSITORY,
          jiraRestRepository: JIRA_REST_REPOSITORY,
          jiraRepository: JIRA_REPOSITORY),
      HistoryPage(key: historyKey,jiraRepository: JIRA_REPOSITORY,jiraRestRepository: JIRA_REST_REPOSITORY),
      SettingsPage(key: settingKey,viewModel: settingsViewModel)
    ];
  }


  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧菜单栏
          Container(
            width: 120,
            color: Colors.grey[200],
            child: ListView.builder(
              itemCount: menus.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(menus[index]),
                  selected: _selectedIndex == index,
                  onTap: () {
                    _selectedIndex = index;
                    keyList[_selectedIndex].currentState?.onTabSelect();
                    setState(() {

                    });
                  },
                );
              },
            ),
          ),
          // 右侧展示区域
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}

abstract class TabPageState <T extends StatefulWidget> extends State<T> with OnTabSelectedListener{

}

mixin OnTabSelectedListener{
  void onTabSelect();
}

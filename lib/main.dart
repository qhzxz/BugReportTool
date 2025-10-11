import 'dart:io';

import 'package:bug_report_tool/database/app_database.dart';
import 'package:bug_report_tool/database/dao/ticket_dao.dart';
import 'package:bug_report_tool/model/app_jira_config.dart';
import 'package:bug_report_tool/page/history_page.dart';
import 'package:bug_report_tool/page/report_page.dart';
import 'package:bug_report_tool/repository/jira_repository.dart';
import 'package:bug_report_tool/repository/jira_rest_repository.dart';
import 'package:bug_report_tool/usecase/create_ticket_usecase.dart';
import 'package:bug_report_tool/usecase/derive_fingerprint_usecase.dart';
import 'package:bug_report_tool/usecase/list_device_usecase.dart';
import 'package:bug_report_tool/usecase/load_config_usecase.dart';
import 'package:bug_report_tool/usecase/query_version_usecase.dart';
import 'package:bug_report_tool/usecase/start_logcat_usecase.dart';
import 'package:bug_report_tool/usecase/start_screen_record_usecase.dart';
import 'package:bug_report_tool/usecase/stop_logcat_usecase.dart';
import 'package:bug_report_tool/usecase/stop_screen_record_usecase.dart';
import 'package:bug_report_tool/util/util.dart';
import 'package:bug_report_tool/view/app_menu.dart';
import 'package:bug_report_tool/view/edit_text.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_size/window_size.dart';

import 'repository/jira_config_repository.dart';
import 'viewmodel/report_view_model.dart';
import 'package:path/path.dart' as p;



final JiraConfigRepository CONFIG_REPOSITORY = JiraConfigRepository();
final JiraRestRepository TICKET_REST_REPOSITORY = JiraRestRepository();
late final JiraRepository JIRA_REPOSITORY;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'db.sqlite'));
  JIRA_REPOSITORY = JiraRepository(TicketDao(AppDatabase(file)));
  if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
    setWindowTitle('BugReportTool');
    setWindowMinSize(const Size(1280, 720));
    setWindowFrame(const Rect.fromLTWH(100, 100, 1280, 720));
  }
  try {
    runApp(const MyApp());
  } catch (e) {
    print("启动异常：$e");
  }
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

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ReportViewModel viewModel = ReportViewModel();
  final List<String> menus = ['上报BUG', '历史记录'];

  late final List<Widget> pages;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    pages = [
      ReportPage(viewModel: viewModel,
          jiraConfigRepository: CONFIG_REPOSITORY,
          jiraRestRepository: TICKET_REST_REPOSITORY,
          jiraRepository: JIRA_REPOSITORY),
      HistoryPage(jiraRepository: JIRA_REPOSITORY,jiraRestRepository: TICKET_REST_REPOSITORY)
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
                    setState(() {
                      _selectedIndex = index;
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

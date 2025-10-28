import 'package:bug_report_tool/main.dart';
import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/repository/jira_repository.dart';
import 'package:bug_report_tool/repository/jira_rest_repository.dart';
import 'package:bug_report_tool/usecase/get_ticket_usecase.dart';
import 'package:bug_report_tool/usecase/reupload_ticket_usecase.dart';
import 'package:bug_report_tool/widget//ticket_card.dart';
import 'package:bug_report_tool/viewmodel/history_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/status.dart';
import '../model/ticket.dart';
import '../widget/loading_dialog.dart';

class HistoryPage extends StatefulWidget {
  final JiraRepository _jiraRepository;
  final JiraRestRepository _jiraRestRepository;

  const HistoryPage({super.key, required JiraRepository jiraRepository, required JiraRestRepository jiraRestRepository}) : _jiraRepository = jiraRepository, _jiraRestRepository = jiraRestRepository;



  @override
  State<StatefulWidget> createState() {
    return HistoryPageState(_jiraRepository,_jiraRestRepository);
  }
}

class HistoryPageState extends TabPageState<HistoryPage> {
  final JiraRepository _jiraRepository;
  final JiraRestRepository _jiraRestRepository;
  final HistoryViewModel historyViewModel = HistoryViewModel();

  HistoryPageState(this._jiraRepository, this._jiraRestRepository);

  @override
  void didUpdateWidget(covariant HistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('_HistoryPageState didUpdateWidget');
  }

  @override
  void initState() {
    super.initState();
    GetTicketUsecase(_jiraRepository).execute().then((r) {
      if (r is Success) {
        setState(() {
          historyViewModel.updateHistory((r as Success<List<Ticket>>).result);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Ticket> list = historyViewModel.getHistory();
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(right: 20,top: 10,left: 20,bottom: 10),
        child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            return TicketCard(
              context: context,
              createTime: list[index].createdAt,
              ticketTitle: list[index].title,
              status: list[index].status,
              ticketId: list[index].ticketId,
              urlStr:  'https://jira.telenav.com:8443/browse/${list[index].ticketId}',
              callback: () {
                if (list[index].status!=Status.JIRA_ATTACHMENTS_UPLOADED) {
                  showDialog(context: context,
                      barrierDismissible: false,
                      builder: (context) => LoadingDialog(text: '正在重新上报BUG...'));
                  ReuploadTicketUsecase(
                      list[index], _jiraRestRepository, _jiraRepository)
                      .execute()
                      .then((r) {
                    Navigator.of(context).pop();
                    if (r is Success<Ticket>) {
                      GetTicketUsecase(_jiraRepository).execute().then((r) {
                        if (r is Success) {
                          setState(() {
                            historyViewModel.updateHistory((r as Success<List<Ticket>>).result);
                          });
                        }
                      });
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
                    }}).catchError((e){
                    Navigator.of(context).pop();
                  });
                }
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void onTabSelect() {
    GetTicketUsecase(_jiraRepository).execute().then((r) {
      if (r is Success) {
        setState(() {
          historyViewModel.updateHistory((r as Success<List<Ticket>>).result);
        });
      }
    });
  }
}

import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/repository/jira_repository.dart';
import 'package:bug_report_tool/repository/jira_rest_repository.dart';
import 'package:bug_report_tool/usecase/get_ticket_usecase.dart';
import 'package:bug_report_tool/usecase/reupload_ticket_usecase.dart';
import 'package:bug_report_tool/widget//ticket_card.dart';
import 'package:bug_report_tool/viewmodel/history_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/status.dart';
import '../model/ticket.dart';

class HistoryPage extends StatefulWidget {
  final JiraRepository _jiraRepository;
  final JiraRestRepository _jiraRestRepository;

  const HistoryPage({super.key, required JiraRepository jiraRepository, required JiraRestRepository jiraRestRepository}) : _jiraRepository = jiraRepository, _jiraRestRepository = jiraRestRepository;



  @override
  State<StatefulWidget> createState() {
    return _HistoryPageState(_jiraRepository,_jiraRestRepository);
  }
}

class _HistoryPageState extends State<HistoryPage> {
  final JiraRepository _jiraRepository;
  final JiraRestRepository _jiraRestRepository;
  final HistoryViewModel historyViewModel = HistoryViewModel();

  _HistoryPageState(this._jiraRepository, this._jiraRestRepository);



  @override
  void initState() {
    super.initState();
    GetTicketUsecase(_jiraRepository).execute().then((r) {
      setState(() {
        historyViewModel.updateHistory(r);
      });
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
              callback: () {
                if (list[index].status!=Status.JIRA_ATTACHMENTS_UPLOADED) {
                  ReuploadTicketUsecase(
                      list[index], _jiraRestRepository, _jiraRepository)
                      .execute()
                      .then((r) {
                    if (r is Success) {
                      GetTicketUsecase(_jiraRepository).execute().then((r) {
                        setState(() {
                          historyViewModel.updateHistory(r);
                        });
                      });
                    }
                  });
                }
              },
            );
          },
        ),
      ),
    );
  }
}

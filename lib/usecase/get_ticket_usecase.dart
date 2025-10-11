import 'dart:isolate';

import 'package:bug_report_tool/model/ticket.dart';
import 'package:bug_report_tool/repository/jira_repository.dart';
import 'package:bug_report_tool/usecase/usecase.dart';

class GetTicketUsecase extends UseCase<List<Ticket>>{
  final JiraRepository _jiraRepository;

  GetTicketUsecase(this._jiraRepository);

  @override
  Future<List<Ticket>> execute() {
    return Isolate.run(_jiraRepository.getAll);
  }

}
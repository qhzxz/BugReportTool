
import 'dart:io';
import 'dart:isolate';

import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/model/status.dart';
import 'package:bug_report_tool/model/ticket.dart';
import 'package:bug_report_tool/repository/ticket_repository.dart';
import 'package:bug_report_tool/repository/jira_rest_repository.dart';
import 'package:bug_report_tool/repository/resp/create_ticket_resp.dart';
import 'package:bug_report_tool/usecase/report_bug_usecase.dart';
import 'package:bug_report_tool/usecase/report_ticket_usecase.dart';
import 'package:bug_report_tool/usecase/upload_file_usecase.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:flutter/foundation.dart';

class ReuploadTicketUsecase extends UseCase<Ticket>{
  final Ticket _ticket;
  final JiraRestRepository _jiraRestRepository;
  final TicketRepository _repository;

  ReuploadTicketUsecase(this._ticket, this._jiraRestRepository, this._repository);


  @override
  Future<Result<Ticket>> run() async{
    Ticket temp = _ticket;
    if (temp.status == Status.JIRA_SAVED) {
      try {
        var result = await ReportTicketUseCase(
            _jiraRestRepository, _repository, temp).execute();
        if (result is Success<Ticket>) {
          temp = result.result;
        }
      }
      catch (e) {
        return Error(exception: e);
      }
    }
    if (temp.status == Status.JIRA_CREATED) {
      try {
        var result = await UploadFileUsecase(
            temp, _jiraRestRepository, _repository).execute();
        if (result is Success<Ticket>) {
          temp = result.result;
        }
      } catch (e) {
        return Error(exception: e);
      }
    }
    return Success(temp);

  }

}
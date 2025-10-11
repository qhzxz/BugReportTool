
import 'dart:io';
import 'dart:isolate';

import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/model/status.dart';
import 'package:bug_report_tool/model/ticket.dart';
import 'package:bug_report_tool/repository/jira_repository.dart';
import 'package:bug_report_tool/repository/jira_rest_repository.dart';
import 'package:bug_report_tool/repository/resp/create_ticket_resp.dart';
import 'package:bug_report_tool/usecase/upload_file_usecase.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:flutter/foundation.dart';

class ReuploadTicketUsecase extends UseCase<Result>{
  final Ticket _ticket;
  final JiraRestRepository _jiraRestRepository;
  final JiraRepository _repository;

  ReuploadTicketUsecase(this._ticket, this._jiraRestRepository, this._repository);

  @override
  Future<Result> execute() async {
    Ticket temp = _ticket;
    if (temp.status == Status.JIRA_SAVED) {
      try {
        CreateTicketResp? resp = await compute(
            _jiraRestRepository.createTicket, temp.fieldsJson);
        if (resp != null) {
          if (resp.key != null) {
            temp =
                temp.copyWith(ticketId: resp.key, status: Status.JIRA_CREATED);
            await compute(_repository.updateTicket, temp);
          }
        }
      }
      catch (e) {
        return Error(exception: e);
      }
    }
    if (temp.status == Status.JIRA_CREATED) {
      try {
        bool success = await UploadFileUsecase(
            temp.ticketId!, temp.attachments, _jiraRestRepository);
        if (success) {
          temp = temp.copyWith(
              status: Status.JIRA_ATTACHMENTS_UPLOADED, finishedAt: DateTime
              .now()
              .millisecondsSinceEpoch);
          await compute(_repository.updateTicket, temp);
          await Isolate.run(() {
            for (var path in temp.attachments) {
              File file = File(path);
              if (file.existsSync()) {
                file.deleteSync();
              }
            }
          });
        }
      } catch (e) {
        return Error(exception: e);
      }
    }
    return Success(temp);
  }

}
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:isolate';

import 'package:bug_report_tool/model/status.dart';
import 'package:bug_report_tool/model/ticket.dart';
import 'package:bug_report_tool/repository/project_config_repository.dart';
import 'package:bug_report_tool/repository/ticket_repository.dart';
import 'package:bug_report_tool/repository/jira_rest_repository.dart';
import 'package:bug_report_tool/repository/resp/create_ticket_resp.dart';
import 'package:bug_report_tool/usecase/report_ticket_usecase.dart';
import 'package:bug_report_tool/usecase/update_ticket_usecase.dart';
import 'package:bug_report_tool/usecase/upload_file_usecase.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../model/app_jira_config.dart';
import '../model/jira_field_config.dart';
import '../model/result.dart';
import '../util/util.dart';
import 'create_ticket_usecase.dart';

class ReportBugUseCase extends UseCase<Ticket> {
  final TicketRepository _ticketRepository;
  final JiraRestRepository _jiraRestRepository;
  final CreateTicketParam _param;


  ReportBugUseCase(this._ticketRepository,
      this._jiraRestRepository, this._param);

  @override
  Future<Result<Ticket>> run() async {
    var result = await CreateTicketUseCase(_ticketRepository, _param)
        .execute();
    if (result is Error) {
      return result;
    }
    var ticket = (result as Success<Ticket>).result;
    result = await ReportTicketUseCase(_jiraRestRepository,_ticketRepository, ticket).execute();
    if (result is Error) {
      return result;
    }
    ticket = (result as Success<Ticket>).result;
    var id = ticket.ticketId;
    if (id != null) {
      var uploadResult = await UploadFileUsecase(
          ticket, _jiraRestRepository,_ticketRepository)
          .execute();
      if (uploadResult is Error) {
        return result;
      }
    }
    return result;
  }
}


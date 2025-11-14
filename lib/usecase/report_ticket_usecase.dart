import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:isolate';

import 'package:bug_report_tool/model/status.dart';
import 'package:bug_report_tool/model/ticket.dart';
import 'package:bug_report_tool/repository/ticket_repository.dart';
import 'package:bug_report_tool/repository/jira_rest_repository.dart';
import 'package:bug_report_tool/repository/resp/create_ticket_resp.dart';
import 'package:bug_report_tool/usecase/update_ticket_usecase.dart';
import 'package:bug_report_tool/usecase/upload_file_usecase.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../model/app_jira_config.dart';
import '../model/jira_field_config.dart';
import '../model/result.dart';
import '../util/util.dart';

class ReportTicketUseCase extends UseCase<Ticket> {
  final JiraRestRepository _jiraRestRepository;
  final TicketRepository _ticketRepository;
  final Ticket _param;


  ReportTicketUseCase(this._jiraRestRepository, this._ticketRepository,
      this._param);

  @override
  Future<Result<Ticket>> run() async {
    CreateTicketResp? ticketResp;
    try {
      ticketResp =
      await compute(_jiraRestRepository.createTicket, _param.fieldsJson);
    } catch (e) {
      return Error(exception: e);
    }
    if (ticketResp != null) {
      var key = ticketResp.key;
      if (key != null) {
        var result = _param.copyWith(
            ticketId: key, status: Status.JIRA_CREATED, url: ticketResp.self);
        await UpdateTicketUseCase(_ticketRepository, result).execute();
        return Success(result);
      } else {
        return Error(exception: ticketResp.errors);
      }
    } else {
      return Error(exception: '响应异常');
    }
  }
}
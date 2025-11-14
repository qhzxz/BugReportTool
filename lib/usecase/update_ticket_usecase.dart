import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:isolate';

import 'package:bug_report_tool/model/status.dart';
import 'package:bug_report_tool/model/ticket.dart';
import 'package:bug_report_tool/repository/ticket_repository.dart';
import 'package:bug_report_tool/repository/jira_rest_repository.dart';
import 'package:bug_report_tool/repository/resp/create_ticket_resp.dart';
import 'package:bug_report_tool/usecase/upload_file_usecase.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../model/app_jira_config.dart';
import '../model/jira_field_config.dart';
import '../model/result.dart';
import '../util/util.dart';

class UpdateTicketUseCase extends UseCase<Ticket> {
  final TicketRepository _jiraRepository;
  final Ticket _param;

  UpdateTicketUseCase(this._jiraRepository, this._param);

  @override
  Future<Result<Ticket>> run() async {
    bool result = await compute(_jiraRepository.updateTicket, _param);
    if (result) {
      return Success(_param);
    } else {
      return Error(exception: '更新失败');
    }
  }
}

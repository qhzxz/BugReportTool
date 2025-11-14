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

class CreateTicketUseCase extends UseCase<Ticket> {
  final TicketRepository _jiraRepository;
  final CreateTicketParam _param;

  CreateTicketUseCase(this._jiraRepository,
      this._param);


  String _generateJiraFields(CreateTicketParam param) {
    JiraFieldConfig jiraFields = param.appJiraConf.jiraFields;
    Map<String, dynamic> map = {};
    map.addAll(jiraFields.fields);
    map['summary'] = param.ticketTitle;
    map['description'] = param.ticketDescription;
    if (param.environment != null) {
      map['environment'] = jsonEncode(param.environment);
    }
    return jsonEncode(jiraFields.copy(fields: map));
  }


  Ticket _generateTicket(String id, String jiraField, CreateTicketParam param) {
    Map<String, dynamic> map = param.appJiraConf.jiraFields.fields;
    String key = map['project']['key'];
    String reporter = map['reporter']['emailAddress'];
    String assignee = map['assignee']['emailAddress'];
    return Ticket(
        id,
        null,
        key,
        param.ticketTitle,
        reporter,
        assignee,
        jiraField,
        param.filePathList,
        param.appJiraConf.packageName,
        Status.JIRA_SAVED,
        DateTime
            .now()
            .millisecondsSinceEpoch,
        null,
        null);
  }

  @override
  Future<Result<Ticket>> run() async {
    String id = Uuid().v4();
    String jiraField = _generateJiraFields(_param);
    Ticket ticket = _generateTicket(id, jiraField, _param);
    bool result = await compute(_jiraRepository.saveTicket, ticket);
    if (result) {
      return Success(ticket);
    } else {
      return Error(exception: '保存失败');
    }
  }
}

class CreateTicketParam {
  final ProjectConfig appJiraConf;
  final String ticketTitle;
  final String ticketDescription;
  final List<String> filePathList;
  final Map<String, String>? environment;

  CreateTicketParam(
    this.appJiraConf,
    this.ticketTitle,
    this.ticketDescription,
    this.filePathList,
    this.environment,
  );
}

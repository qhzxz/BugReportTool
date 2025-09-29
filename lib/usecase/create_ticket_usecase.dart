import 'dart:convert';


import 'package:bug_report_tool/model/ticket.dart';
import 'package:bug_report_tool/repository/jira_ticket_repository.dart';
import 'package:flutter/foundation.dart';

import '../model/app_jira_config.dart';

Future<Ticket?> CreateTicketUseCase(JiraTicketRepository jiraTicketRepository,
    CreateTicketParam param) async {
  return compute(_CreateTicketUseCase, _Context(param, jiraTicketRepository));
}

Future<Ticket?> _CreateTicketUseCase(_Context c) async {
  Map<String, dynamic> map = c.param.appJiraConf.jiraFields.fields;
  map['summary'] = c.param.ticketTitle;
  map['description'] = c.param.ticketDescription;
  if (c.param.environment != null) {
    map['environment'] = jsonEncode(c.param.environment);
  }
  String jsonParam = jsonEncode(c.param.appJiraConf.jiraFields);
  print("创建ticket jsonParam:$jsonParam");
  // final result = c.repository.createTicket(jsonParam);
  // try {
  //   return result;
  // } catch (e) {
  //   print("创建ticket失败:$e");
  // }
  return null;
}


class _Context{
  CreateTicketParam param;
  JiraTicketRepository repository;

  _Context(this.param, this.repository);
}
class CreateTicketParam {
  final AppJiraConfig appJiraConf;
  final String ticketTitle;
  final String ticketDescription;
  final String? mediaFilePath;
  final Map<String,String>? environment;
  CreateTicketParam(this.appJiraConf, this.ticketTitle, this.ticketDescription,
      this.mediaFilePath, this.environment);


}
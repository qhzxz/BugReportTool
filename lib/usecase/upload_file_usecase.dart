import 'package:flutter/foundation.dart';

import '../repository/jira_rest_repository.dart';

Future<bool> UploadFileUsecase(
  String id,
  List<String> uploadFiles,
  JiraRestRepository jiraTicketRepository,
) async {
  return compute(
    _UploadFileUsecase,
    _Param(id, uploadFiles, jiraTicketRepository),
  );
}

Future<bool> _UploadFileUsecase(_Param param) async {
  return param.jiraTicketRepository.addAttachments(
    param.ticketId,
    param.filePathList,
  );
}

class _Param {
  String ticketId;
  List<String> filePathList;
  JiraRestRepository jiraTicketRepository;

  _Param(this.ticketId, this.filePathList, this.jiraTicketRepository);
}

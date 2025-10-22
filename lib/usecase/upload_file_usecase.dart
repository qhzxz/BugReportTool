import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:flutter/foundation.dart';

import '../repository/jira_rest_repository.dart';


class UploadFileUsecase extends UseCase<bool> {
  String _id;
  List<String> _uploadFiles;
  JiraRestRepository _jiraTicketRepository;


  UploadFileUsecase(this._id, this._uploadFiles, this._jiraTicketRepository);

  @override
  Future<Result<bool>> run() async {
    return Success(await compute(
      _UploadFileUsecase,
      _Param(_id, _uploadFiles, _jiraTicketRepository),
    ));
  }

  Future<bool> _UploadFileUsecase(_Param param) async {
    return param.jiraTicketRepository.addAttachments(
      param.ticketId,
      param.filePathList,
    );
  }

}


class _Param {
  String ticketId;
  List<String> filePathList;
  JiraRestRepository jiraTicketRepository;

  _Param(this.ticketId, this.filePathList, this.jiraTicketRepository);
}

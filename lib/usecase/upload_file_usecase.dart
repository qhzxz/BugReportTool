import 'dart:io';
import 'dart:isolate';

import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/model/ticket.dart';
import 'package:bug_report_tool/repository/ticket_repository.dart';
import 'package:bug_report_tool/usecase/update_ticket_usecase.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:flutter/foundation.dart';

import '../model/status.dart';
import '../repository/jira_rest_repository.dart';


class UploadFileUsecase extends UseCase<Ticket> {
  Ticket _ticket;
  JiraRestRepository _jiraTicketRepository;
  TicketRepository _ticketRepository;


  UploadFileUsecase(this._ticket, this._jiraTicketRepository,
      this._ticketRepository);

  @override
  Future<Result<Ticket>> run() async {
    var ticketId = _ticket.ticketId;
    if (ticketId != null) {
      var result = await compute(
        _UploadFileUsecase,
        _Param(ticketId, _ticket.attachments, _jiraTicketRepository),
      );
      if (result) {
        var r = _ticket.copyWith(
            status: Status.JIRA_ATTACHMENTS_UPLOADED, finishedAt: DateTime
            .now()
            .millisecondsSinceEpoch);
        await UpdateTicketUseCase(_ticketRepository, r).execute();
        var list = r.attachments;
        if (list.isNotEmpty) {
          await Isolate.run(() async {
            for (var path in list) {
              await File(path).delete();
            }
          });
        }
        return Success(r);
      }
    }

    return Error(exception: 'ticket id 为空');
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

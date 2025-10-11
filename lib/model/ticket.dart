import 'package:bug_report_tool/database/app_database.dart';
import 'package:bug_report_tool/model/status.dart';

class Ticket {
  final String id;

  final String? ticketId;

  final String projectKey;
  final String title;
  final String reporter;
  final String assignee;
  final String fieldsJson;
  final List<String> attachments;
  final String appPackageName;
  Status status;
  final int createdAt;
  int? finishedAt;

  Ticket(this.id,
      this.ticketId,
      this.projectKey,
      this.title,
      this.reporter,
      this.assignee,
      this.fieldsJson,
      this.attachments,
      this.appPackageName,
      this.status,
      this.createdAt,
      this.finishedAt);

  TicketEntityData toEntity() {
    return TicketEntityData(
        id: id,
        ticketId: ticketId,
        projectKey: projectKey,
        title: title,
        reporter: reporter,
        assignee: assignee,
        fieldsJson: fieldsJson,
        attachments: attachments,
        appPackageName: appPackageName,
        status: status,
        createdAt: createdAt,
        finishedAt: finishedAt);
  }

  Ticket copyWith({String? id,
    String? ticketId,
    String? projectKey,
    String? title,
    String? reporter,
    String? assignee,
    String? fieldsJson,
    List<String>? attachments,
    String? appPackageName,
    Status? status,
    int, createdAt,
    int? finishedAt}) =>
      Ticket(
          id ?? this.id,
          ticketId ?? this.ticketId,
          projectKey ?? this.projectKey,
          title ?? this.title,
          reporter ?? this.reporter,
          assignee ?? this.assignee,
          fieldsJson ?? this.fieldsJson,
          attachments ?? this.attachments,
          appPackageName ?? this.appPackageName,
          status ?? this.status,
          createdAt ?? this.createdAt,
          finishedAt ?? this.finishedAt
      );

  @override
  String toString() {
    return 'Ticket{id: $id, ticketId: $ticketId, projectKey: $projectKey, title: $title, reporter: $reporter, assignee: $assignee, fieldsJson: $fieldsJson, attachments: $attachments, appPackageName: $appPackageName, status: $status, createdAt: $createdAt, finishedAt: $finishedAt}';
  }


}

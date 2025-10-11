import 'package:bug_report_tool/database/app_database.dart';
import 'package:drift/drift.dart';

class TicketDao {
  final AppDatabase database;

  TicketDao(this.database);

  Future<List<TicketEntityData>> get() async {
    return database.select(database.ticketEntity).get();
  }

  Future<int> insert(TicketEntityData data) async {
    return database.into(database.ticketEntity).insert(TicketEntityCompanion(
        id: Value(data.id),
        ticketId: Value(data.ticketId),
        projectKey: Value(data.projectKey),
        title: Value(data.title),
        reporter: Value(data.reporter),
        assignee: Value(data.assignee),
        fieldsJson: Value(data.fieldsJson),
        attachments: Value(data.attachments),
        appPackageName: Value(data.appPackageName),
        status: Value(data.status),
        createdAt: Value(data.createdAt),
        finishedAt: Value(data.finishedAt)
    ));
  }

  Future<bool> update(TicketEntityData data) async {
    return database.update(database.ticketEntity).replace(data);
  }
}
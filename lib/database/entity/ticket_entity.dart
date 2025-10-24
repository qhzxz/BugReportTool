
import 'dart:convert';

import 'package:bug_report_tool/database/app_database.dart';
import 'package:bug_report_tool/model/status.dart';
import 'package:bug_report_tool/model/ticket.dart';
import 'package:drift/drift.dart';


class TicketEntity extends Table {

  @override
  String get tableName => 'ticket_history';

  TextColumn get id => text().customConstraint('UNIQUE NOT NULL')();

  TextColumn get ticketId =>
      text().named('ticket_id').customConstraint('UNIQUE').nullable()();

  TextColumn get projectKey => text().named('project_key')();

  TextColumn get title => text()();

  TextColumn get reporter => text()();

  TextColumn get assignee => text()();

  TextColumn get fieldsJson => text().named('fields_json')();

  TextColumn get attachments => text().map(const StringListConverter())();

  TextColumn get appPackageName => text().named('app_package_name')();

  IntColumn get status => integer().map(const StatusConverter())();

  IntColumn get createdAt => integer().named('created_at')();

  IntColumn get finishedAt => integer().named('finished_at').nullable()();

  TextColumn get url => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    return fromDb.isNotEmpty ? (json.decode(fromDb) as List).cast<String>() : [];
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value);
  }
}

class StatusConverter extends TypeConverter<Status, int> {
  const StatusConverter();

  @override
  Status fromSql(int fromDb) {
    return Status.values[fromDb];
  }

  @override
  int toSql(Status value) {
    return value.index;
  }
}

Ticket toTicket(TicketEntityData d) {
  return Ticket(
      d.id,
      d.ticketId,
      d.projectKey,
      d.title,
      d.reporter,
      d.assignee,
      d.fieldsJson,
      d.attachments,
      d.appPackageName,
      d.status,
      d.createdAt,
      d.finishedAt,
      d.url
  );
}

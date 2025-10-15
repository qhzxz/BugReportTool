import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'dart:io';
import '../model/status.dart';
import 'entity/ticket_entity.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [TicketEntity])
class AppDatabase extends _$AppDatabase {
  AppDatabase(File dbDir) : super(_openConnection(dbDir));

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection(File dbDir) {
  return LazyDatabase(() async {
    return NativeDatabase.createInBackground(dbDir);
  });
}

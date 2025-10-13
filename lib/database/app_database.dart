import 'package:drift/drift.dart';
import 'package:drift/web.dart';
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
  if (Platform.isMacOS || Platform.isWindows) {
    return LazyDatabase(() async {
      return NativeDatabase.createInBackground(dbDir);
    });
  } else {
    return LazyDatabase(() async {
      return WebDatabase('my_db'); // Web 自动用 IndexedDB
    });
  }
}

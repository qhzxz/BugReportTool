// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TicketEntityTable extends TicketEntity
    with TableInfo<$TicketEntityTable, TicketEntityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TicketEntityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE NOT NULL',
  );
  static const VerificationMeta _ticketIdMeta = const VerificationMeta(
    'ticketId',
  );
  @override
  late final GeneratedColumn<String> ticketId = GeneratedColumn<String>(
    'ticket_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'UNIQUE',
  );
  static const VerificationMeta _projectKeyMeta = const VerificationMeta(
    'projectKey',
  );
  @override
  late final GeneratedColumn<String> projectKey = GeneratedColumn<String>(
    'project_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reporterMeta = const VerificationMeta(
    'reporter',
  );
  @override
  late final GeneratedColumn<String> reporter = GeneratedColumn<String>(
    'reporter',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assigneeMeta = const VerificationMeta(
    'assignee',
  );
  @override
  late final GeneratedColumn<String> assignee = GeneratedColumn<String>(
    'assignee',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldsJsonMeta = const VerificationMeta(
    'fieldsJson',
  );
  @override
  late final GeneratedColumn<String> fieldsJson = GeneratedColumn<String>(
    'fields_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  attachments = GeneratedColumn<String>(
    'attachments',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($TicketEntityTable.$converterattachments);
  static const VerificationMeta _appPackageNameMeta = const VerificationMeta(
    'appPackageName',
  );
  @override
  late final GeneratedColumn<String> appPackageName = GeneratedColumn<String>(
    'app_package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Status, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Status>($TicketEntityTable.$converterstatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<int> finishedAt = GeneratedColumn<int>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ticketId,
    projectKey,
    title,
    reporter,
    assignee,
    fieldsJson,
    attachments,
    appPackageName,
    status,
    createdAt,
    finishedAt,
    url,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ticket_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<TicketEntityData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ticket_id')) {
      context.handle(
        _ticketIdMeta,
        ticketId.isAcceptableOrUnknown(data['ticket_id']!, _ticketIdMeta),
      );
    }
    if (data.containsKey('project_key')) {
      context.handle(
        _projectKeyMeta,
        projectKey.isAcceptableOrUnknown(data['project_key']!, _projectKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_projectKeyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('reporter')) {
      context.handle(
        _reporterMeta,
        reporter.isAcceptableOrUnknown(data['reporter']!, _reporterMeta),
      );
    } else if (isInserting) {
      context.missing(_reporterMeta);
    }
    if (data.containsKey('assignee')) {
      context.handle(
        _assigneeMeta,
        assignee.isAcceptableOrUnknown(data['assignee']!, _assigneeMeta),
      );
    } else if (isInserting) {
      context.missing(_assigneeMeta);
    }
    if (data.containsKey('fields_json')) {
      context.handle(
        _fieldsJsonMeta,
        fieldsJson.isAcceptableOrUnknown(data['fields_json']!, _fieldsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldsJsonMeta);
    }
    if (data.containsKey('app_package_name')) {
      context.handle(
        _appPackageNameMeta,
        appPackageName.isAcceptableOrUnknown(
          data['app_package_name']!,
          _appPackageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_appPackageNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TicketEntityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TicketEntityData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ticketId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ticket_id'],
      ),
      projectKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      reporter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reporter'],
      )!,
      assignee: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assignee'],
      )!,
      fieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields_json'],
      )!,
      attachments: $TicketEntityTable.$converterattachments.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}attachments'],
        )!,
      ),
      appPackageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_package_name'],
      )!,
      status: $TicketEntityTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finished_at'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
    );
  }

  @override
  $TicketEntityTable createAlias(String alias) {
    return $TicketEntityTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converterattachments =
      const StringListConverter();
  static TypeConverter<Status, int> $converterstatus = const StatusConverter();
}

class TicketEntityData extends DataClass
    implements Insertable<TicketEntityData> {
  final String id;
  final String? ticketId;
  final String projectKey;
  final String title;
  final String reporter;
  final String assignee;
  final String fieldsJson;
  final List<String> attachments;
  final String appPackageName;
  final Status status;
  final int createdAt;
  final int? finishedAt;
  final String? url;
  const TicketEntityData({
    required this.id,
    this.ticketId,
    required this.projectKey,
    required this.title,
    required this.reporter,
    required this.assignee,
    required this.fieldsJson,
    required this.attachments,
    required this.appPackageName,
    required this.status,
    required this.createdAt,
    this.finishedAt,
    this.url,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || ticketId != null) {
      map['ticket_id'] = Variable<String>(ticketId);
    }
    map['project_key'] = Variable<String>(projectKey);
    map['title'] = Variable<String>(title);
    map['reporter'] = Variable<String>(reporter);
    map['assignee'] = Variable<String>(assignee);
    map['fields_json'] = Variable<String>(fieldsJson);
    {
      map['attachments'] = Variable<String>(
        $TicketEntityTable.$converterattachments.toSql(attachments),
      );
    }
    map['app_package_name'] = Variable<String>(appPackageName);
    {
      map['status'] = Variable<int>(
        $TicketEntityTable.$converterstatus.toSql(status),
      );
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<int>(finishedAt);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    return map;
  }

  TicketEntityCompanion toCompanion(bool nullToAbsent) {
    return TicketEntityCompanion(
      id: Value(id),
      ticketId: ticketId == null && nullToAbsent
          ? const Value.absent()
          : Value(ticketId),
      projectKey: Value(projectKey),
      title: Value(title),
      reporter: Value(reporter),
      assignee: Value(assignee),
      fieldsJson: Value(fieldsJson),
      attachments: Value(attachments),
      appPackageName: Value(appPackageName),
      status: Value(status),
      createdAt: Value(createdAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
    );
  }

  factory TicketEntityData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TicketEntityData(
      id: serializer.fromJson<String>(json['id']),
      ticketId: serializer.fromJson<String?>(json['ticketId']),
      projectKey: serializer.fromJson<String>(json['projectKey']),
      title: serializer.fromJson<String>(json['title']),
      reporter: serializer.fromJson<String>(json['reporter']),
      assignee: serializer.fromJson<String>(json['assignee']),
      fieldsJson: serializer.fromJson<String>(json['fieldsJson']),
      attachments: serializer.fromJson<List<String>>(json['attachments']),
      appPackageName: serializer.fromJson<String>(json['appPackageName']),
      status: serializer.fromJson<Status>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      finishedAt: serializer.fromJson<int?>(json['finishedAt']),
      url: serializer.fromJson<String?>(json['url']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ticketId': serializer.toJson<String?>(ticketId),
      'projectKey': serializer.toJson<String>(projectKey),
      'title': serializer.toJson<String>(title),
      'reporter': serializer.toJson<String>(reporter),
      'assignee': serializer.toJson<String>(assignee),
      'fieldsJson': serializer.toJson<String>(fieldsJson),
      'attachments': serializer.toJson<List<String>>(attachments),
      'appPackageName': serializer.toJson<String>(appPackageName),
      'status': serializer.toJson<Status>(status),
      'createdAt': serializer.toJson<int>(createdAt),
      'finishedAt': serializer.toJson<int?>(finishedAt),
      'url': serializer.toJson<String?>(url),
    };
  }

  TicketEntityData copyWith({
    String? id,
    Value<String?> ticketId = const Value.absent(),
    String? projectKey,
    String? title,
    String? reporter,
    String? assignee,
    String? fieldsJson,
    List<String>? attachments,
    String? appPackageName,
    Status? status,
    int? createdAt,
    Value<int?> finishedAt = const Value.absent(),
    Value<String?> url = const Value.absent(),
  }) => TicketEntityData(
    id: id ?? this.id,
    ticketId: ticketId.present ? ticketId.value : this.ticketId,
    projectKey: projectKey ?? this.projectKey,
    title: title ?? this.title,
    reporter: reporter ?? this.reporter,
    assignee: assignee ?? this.assignee,
    fieldsJson: fieldsJson ?? this.fieldsJson,
    attachments: attachments ?? this.attachments,
    appPackageName: appPackageName ?? this.appPackageName,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    url: url.present ? url.value : this.url,
  );
  TicketEntityData copyWithCompanion(TicketEntityCompanion data) {
    return TicketEntityData(
      id: data.id.present ? data.id.value : this.id,
      ticketId: data.ticketId.present ? data.ticketId.value : this.ticketId,
      projectKey: data.projectKey.present
          ? data.projectKey.value
          : this.projectKey,
      title: data.title.present ? data.title.value : this.title,
      reporter: data.reporter.present ? data.reporter.value : this.reporter,
      assignee: data.assignee.present ? data.assignee.value : this.assignee,
      fieldsJson: data.fieldsJson.present
          ? data.fieldsJson.value
          : this.fieldsJson,
      attachments: data.attachments.present
          ? data.attachments.value
          : this.attachments,
      appPackageName: data.appPackageName.present
          ? data.appPackageName.value
          : this.appPackageName,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      url: data.url.present ? data.url.value : this.url,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TicketEntityData(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('projectKey: $projectKey, ')
          ..write('title: $title, ')
          ..write('reporter: $reporter, ')
          ..write('assignee: $assignee, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('attachments: $attachments, ')
          ..write('appPackageName: $appPackageName, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('url: $url')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ticketId,
    projectKey,
    title,
    reporter,
    assignee,
    fieldsJson,
    attachments,
    appPackageName,
    status,
    createdAt,
    finishedAt,
    url,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TicketEntityData &&
          other.id == this.id &&
          other.ticketId == this.ticketId &&
          other.projectKey == this.projectKey &&
          other.title == this.title &&
          other.reporter == this.reporter &&
          other.assignee == this.assignee &&
          other.fieldsJson == this.fieldsJson &&
          other.attachments == this.attachments &&
          other.appPackageName == this.appPackageName &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.finishedAt == this.finishedAt &&
          other.url == this.url);
}

class TicketEntityCompanion extends UpdateCompanion<TicketEntityData> {
  final Value<String> id;
  final Value<String?> ticketId;
  final Value<String> projectKey;
  final Value<String> title;
  final Value<String> reporter;
  final Value<String> assignee;
  final Value<String> fieldsJson;
  final Value<List<String>> attachments;
  final Value<String> appPackageName;
  final Value<Status> status;
  final Value<int> createdAt;
  final Value<int?> finishedAt;
  final Value<String?> url;
  final Value<int> rowid;
  const TicketEntityCompanion({
    this.id = const Value.absent(),
    this.ticketId = const Value.absent(),
    this.projectKey = const Value.absent(),
    this.title = const Value.absent(),
    this.reporter = const Value.absent(),
    this.assignee = const Value.absent(),
    this.fieldsJson = const Value.absent(),
    this.attachments = const Value.absent(),
    this.appPackageName = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.url = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TicketEntityCompanion.insert({
    required String id,
    this.ticketId = const Value.absent(),
    required String projectKey,
    required String title,
    required String reporter,
    required String assignee,
    required String fieldsJson,
    required List<String> attachments,
    required String appPackageName,
    required Status status,
    required int createdAt,
    this.finishedAt = const Value.absent(),
    this.url = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectKey = Value(projectKey),
       title = Value(title),
       reporter = Value(reporter),
       assignee = Value(assignee),
       fieldsJson = Value(fieldsJson),
       attachments = Value(attachments),
       appPackageName = Value(appPackageName),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<TicketEntityData> custom({
    Expression<String>? id,
    Expression<String>? ticketId,
    Expression<String>? projectKey,
    Expression<String>? title,
    Expression<String>? reporter,
    Expression<String>? assignee,
    Expression<String>? fieldsJson,
    Expression<String>? attachments,
    Expression<String>? appPackageName,
    Expression<int>? status,
    Expression<int>? createdAt,
    Expression<int>? finishedAt,
    Expression<String>? url,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ticketId != null) 'ticket_id': ticketId,
      if (projectKey != null) 'project_key': projectKey,
      if (title != null) 'title': title,
      if (reporter != null) 'reporter': reporter,
      if (assignee != null) 'assignee': assignee,
      if (fieldsJson != null) 'fields_json': fieldsJson,
      if (attachments != null) 'attachments': attachments,
      if (appPackageName != null) 'app_package_name': appPackageName,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (url != null) 'url': url,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TicketEntityCompanion copyWith({
    Value<String>? id,
    Value<String?>? ticketId,
    Value<String>? projectKey,
    Value<String>? title,
    Value<String>? reporter,
    Value<String>? assignee,
    Value<String>? fieldsJson,
    Value<List<String>>? attachments,
    Value<String>? appPackageName,
    Value<Status>? status,
    Value<int>? createdAt,
    Value<int?>? finishedAt,
    Value<String?>? url,
    Value<int>? rowid,
  }) {
    return TicketEntityCompanion(
      id: id ?? this.id,
      ticketId: ticketId ?? this.ticketId,
      projectKey: projectKey ?? this.projectKey,
      title: title ?? this.title,
      reporter: reporter ?? this.reporter,
      assignee: assignee ?? this.assignee,
      fieldsJson: fieldsJson ?? this.fieldsJson,
      attachments: attachments ?? this.attachments,
      appPackageName: appPackageName ?? this.appPackageName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
      url: url ?? this.url,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ticketId.present) {
      map['ticket_id'] = Variable<String>(ticketId.value);
    }
    if (projectKey.present) {
      map['project_key'] = Variable<String>(projectKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (reporter.present) {
      map['reporter'] = Variable<String>(reporter.value);
    }
    if (assignee.present) {
      map['assignee'] = Variable<String>(assignee.value);
    }
    if (fieldsJson.present) {
      map['fields_json'] = Variable<String>(fieldsJson.value);
    }
    if (attachments.present) {
      map['attachments'] = Variable<String>(
        $TicketEntityTable.$converterattachments.toSql(attachments.value),
      );
    }
    if (appPackageName.present) {
      map['app_package_name'] = Variable<String>(appPackageName.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $TicketEntityTable.$converterstatus.toSql(status.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<int>(finishedAt.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TicketEntityCompanion(')
          ..write('id: $id, ')
          ..write('ticketId: $ticketId, ')
          ..write('projectKey: $projectKey, ')
          ..write('title: $title, ')
          ..write('reporter: $reporter, ')
          ..write('assignee: $assignee, ')
          ..write('fieldsJson: $fieldsJson, ')
          ..write('attachments: $attachments, ')
          ..write('appPackageName: $appPackageName, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('url: $url, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TicketEntityTable ticketEntity = $TicketEntityTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [ticketEntity];
}

typedef $$TicketEntityTableCreateCompanionBuilder =
    TicketEntityCompanion Function({
      required String id,
      Value<String?> ticketId,
      required String projectKey,
      required String title,
      required String reporter,
      required String assignee,
      required String fieldsJson,
      required List<String> attachments,
      required String appPackageName,
      required Status status,
      required int createdAt,
      Value<int?> finishedAt,
      Value<String?> url,
      Value<int> rowid,
    });
typedef $$TicketEntityTableUpdateCompanionBuilder =
    TicketEntityCompanion Function({
      Value<String> id,
      Value<String?> ticketId,
      Value<String> projectKey,
      Value<String> title,
      Value<String> reporter,
      Value<String> assignee,
      Value<String> fieldsJson,
      Value<List<String>> attachments,
      Value<String> appPackageName,
      Value<Status> status,
      Value<int> createdAt,
      Value<int?> finishedAt,
      Value<String?> url,
      Value<int> rowid,
    });

class $$TicketEntityTableFilterComposer
    extends Composer<_$AppDatabase, $TicketEntityTable> {
  $$TicketEntityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ticketId => $composableBuilder(
    column: $table.ticketId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectKey => $composableBuilder(
    column: $table.projectKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reporter => $composableBuilder(
    column: $table.reporter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assignee => $composableBuilder(
    column: $table.assignee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get appPackageName => $composableBuilder(
    column: $table.appPackageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Status, Status, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TicketEntityTableOrderingComposer
    extends Composer<_$AppDatabase, $TicketEntityTable> {
  $$TicketEntityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ticketId => $composableBuilder(
    column: $table.ticketId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectKey => $composableBuilder(
    column: $table.projectKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reporter => $composableBuilder(
    column: $table.reporter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assignee => $composableBuilder(
    column: $table.assignee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachments => $composableBuilder(
    column: $table.attachments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appPackageName => $composableBuilder(
    column: $table.appPackageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TicketEntityTableAnnotationComposer
    extends Composer<_$AppDatabase, $TicketEntityTable> {
  $$TicketEntityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ticketId =>
      $composableBuilder(column: $table.ticketId, builder: (column) => column);

  GeneratedColumn<String> get projectKey => $composableBuilder(
    column: $table.projectKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get reporter =>
      $composableBuilder(column: $table.reporter, builder: (column) => column);

  GeneratedColumn<String> get assignee =>
      $composableBuilder(column: $table.assignee, builder: (column) => column);

  GeneratedColumn<String> get fieldsJson => $composableBuilder(
    column: $table.fieldsJson,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get attachments =>
      $composableBuilder(
        column: $table.attachments,
        builder: (column) => column,
      );

  GeneratedColumn<String> get appPackageName => $composableBuilder(
    column: $table.appPackageName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Status, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);
}

class $$TicketEntityTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TicketEntityTable,
          TicketEntityData,
          $$TicketEntityTableFilterComposer,
          $$TicketEntityTableOrderingComposer,
          $$TicketEntityTableAnnotationComposer,
          $$TicketEntityTableCreateCompanionBuilder,
          $$TicketEntityTableUpdateCompanionBuilder,
          (
            TicketEntityData,
            BaseReferences<_$AppDatabase, $TicketEntityTable, TicketEntityData>,
          ),
          TicketEntityData,
          PrefetchHooks Function()
        > {
  $$TicketEntityTableTableManager(_$AppDatabase db, $TicketEntityTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TicketEntityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TicketEntityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TicketEntityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> ticketId = const Value.absent(),
                Value<String> projectKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> reporter = const Value.absent(),
                Value<String> assignee = const Value.absent(),
                Value<String> fieldsJson = const Value.absent(),
                Value<List<String>> attachments = const Value.absent(),
                Value<String> appPackageName = const Value.absent(),
                Value<Status> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> finishedAt = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TicketEntityCompanion(
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
                finishedAt: finishedAt,
                url: url,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> ticketId = const Value.absent(),
                required String projectKey,
                required String title,
                required String reporter,
                required String assignee,
                required String fieldsJson,
                required List<String> attachments,
                required String appPackageName,
                required Status status,
                required int createdAt,
                Value<int?> finishedAt = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TicketEntityCompanion.insert(
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
                finishedAt: finishedAt,
                url: url,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TicketEntityTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TicketEntityTable,
      TicketEntityData,
      $$TicketEntityTableFilterComposer,
      $$TicketEntityTableOrderingComposer,
      $$TicketEntityTableAnnotationComposer,
      $$TicketEntityTableCreateCompanionBuilder,
      $$TicketEntityTableUpdateCompanionBuilder,
      (
        TicketEntityData,
        BaseReferences<_$AppDatabase, $TicketEntityTable, TicketEntityData>,
      ),
      TicketEntityData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TicketEntityTableTableManager get ticketEntity =>
      $$TicketEntityTableTableManager(_db, _db.ticketEntity);
}

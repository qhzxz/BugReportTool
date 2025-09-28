// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jira_field_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JiraFieldConfig _$JiraFieldConfigFromJson(Map<String, dynamic> json) =>
    JiraFieldConfig(
      fields: json['fields'],
      apps: (json['apps'] as List<dynamic>)
          .map((e) => AppInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$JiraFieldConfigToJson(JiraFieldConfig instance) =>
    <String, dynamic>{'fields': instance.fields, 'apps': instance.apps};

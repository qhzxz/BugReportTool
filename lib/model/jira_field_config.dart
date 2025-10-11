import 'dart:core';
import 'app_info.dart';
import 'package:json_annotation/json_annotation.dart';
part 'jira_field_config.g.dart';

@JsonSerializable()
class JiraFieldConfig {
  final dynamic fields;
  final List<AppInfo> apps;

  JiraFieldConfig({required this.fields, required this.apps});

  /// 由生成的代码实现
  factory JiraFieldConfig.fromJson(Map<String, dynamic> json) => _$JiraFieldConfigFromJson(json);

  /// 由生成的代码实现
  Map<String, dynamic> toJson() => _$JiraFieldConfigToJson(this);

  copy({dynamic fields, List<AppInfo>? apps}) =>
      JiraFieldConfig(fields: fields ?? this.fields, apps: apps ?? this.apps);
}
import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
part 'app_info.g.dart';

@JsonSerializable()
class AppInfo {
  final String packageName;
  final List<String>? dependencies;
  AppInfo({required this.packageName,  this.dependencies});

  /// 由生成的代码实现
  factory AppInfo.fromJson(Map<String, dynamic> json) => _$AppInfoFromJson(json);

  /// 由生成的代码实现
  Map<String, dynamic> toJson() => _$AppInfoToJson(this);
}

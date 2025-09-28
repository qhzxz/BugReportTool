import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../model/app_jira_config.dart';
import '../model/jira_field_config.dart';


class JiraConfigRepository {
  Future<Map<String,List<AppJiraConfig>>> loadJsonFilesFromAssets() async {
    // 读取 AssetManifest.json
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);
    // 筛选出 assets/json/ 下的 .json 文件
    final jsonFiles = manifestMap.keys
        .where((String key) => key.startsWith('assets/json/') && key.endsWith('.json'))
        .toList();
    Map<String,List<AppJiraConfig>> result= {};
    for (final path in jsonFiles) {
      final project = path.substring(
          path.lastIndexOf('/') + 1, path.lastIndexOf('.'));
      result[project]=[];
      final jsonString = await rootBundle.loadString(path);
      JiraFieldConfig jiraFieldConfig = JiraFieldConfig.fromJson(
          jsonDecode(jsonString));
      for (var app in jiraFieldConfig.apps) {
        result[project]?.add(AppJiraConfig(
            project, app.packageName, app.dependencies, jiraFieldConfig));
      }
    }
    return result;
  }
}
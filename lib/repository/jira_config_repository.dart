import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:bug_report_tool/usecase/get_file_dir_usecase.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../model/app_jira_config.dart';
import '../model/jira_field_config.dart';


class JiraConfigRepository {

  const JiraConfigRepository();

  Future<Map<String,List<AppJiraConfig>>> loadJsonFilesFromAssets() async {
    final dir = await GetFileDirUsecase();
    String jsonDirPath = '$dir${Platform.pathSeparator}json';
    Directory jsonDir = Directory(jsonDirPath);
    if (!await Isolate.run(() async {
      var bool = await jsonDir.exists();
      if (!bool) {
        await jsonDir.create();
      }
      return bool;
    })) {
      // 读取 AssetManifest.json
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);
      // 筛选出 assets/json/ 下的 .json 文件
      final jsonFiles = manifestMap.keys
          .where((String key) => key.startsWith('assets/json/') && key.endsWith('.json'))
          .toList();
      for (final path in jsonFiles) {
        final project = path.substring(
            path.lastIndexOf('/') + 1, path.lastIndexOf('.'));
        final jsonString = await rootBundle.loadString(path);
        await Isolate.run(() async {
          File jsonFile = File('$jsonDirPath${Platform.pathSeparator}$project.json');
          if(!await jsonFile.exists()){
            await jsonFile.create();
            IOSink? sink = jsonFile.openWrite(mode: FileMode.write);
            try {
              sink.write(jsonString);
            } catch (e) {
              print('$e');
            } finally {
              await sink.flush();
              await sink.close();
            }
          }
        });
      }
    }
    Stream<FileSystemEntity> files = jsonDir.list();
    Map<String,List<AppJiraConfig>> result= {};
    await files.forEach((f) async {
      var path = f.path;
      if (path.endsWith('.json')) {
        final project = path.substring(
            path.lastIndexOf('/') + 1, path.lastIndexOf('.'));
        result[project]=[];
        String json = await Isolate.run(() async {
          return await File(path).readAsString();
        });
        JiraFieldConfig jiraFieldConfig = JiraFieldConfig.fromJson(
            jsonDecode(json));
        for (var app in jiraFieldConfig.apps) {
          result[project]?.add(AppJiraConfig(
              project, app.packageName, app.dependencies, jiraFieldConfig));
        }
      }
    });
    return result;
  }
}
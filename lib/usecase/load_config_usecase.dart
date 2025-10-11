import 'dart:isolate';

import 'package:bug_report_tool/usecase/usecase.dart';

import '../model/app_jira_config.dart';
import '../repository/jira_config_repository.dart';

class LoadConfigUsecase extends UseCase<Map<String,List<AppJiraConfig>>>{

  final JiraConfigRepository jiraConfigRepository;

  LoadConfigUsecase(this.jiraConfigRepository);

  @override
  Future<Map<String,List<AppJiraConfig>>> execute() async {
     return jiraConfigRepository.loadJsonFilesFromAssets();
  }
}
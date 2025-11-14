import 'dart:isolate';

import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/usecase/usecase.dart';

import '../model/app_jira_config.dart';
import '../repository/project_config_repository.dart';

class LoadConfigUsecase
    extends UseCase<Map<String, List<ProjectConfig>>> {
  final ProjectConfigRepository jiraConfigRepository;

  LoadConfigUsecase(this.jiraConfigRepository);

  @override
  Future<Result<Map<String, List<ProjectConfig>>>> run() async {
    return Success(await jiraConfigRepository.loadJsonFilesFromAssets());
  }
}

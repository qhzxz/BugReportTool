import 'dart:core';
import 'jira_field_config.dart';


class ProjectConfig {
  String project;
  String packageName;
  List<String>? dependPackages;
  JiraFieldConfig jiraFields;

  ProjectConfig(
    this.project,
    this.packageName,
    this.dependPackages,
    this.jiraFields,
  );
}




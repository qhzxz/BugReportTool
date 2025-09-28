import 'dart:core';
import 'jira_field_config.dart';


class AppJiraConfig {
  String project;
  String packageName;
  List<String>? dependPackages;
  JiraFieldConfig jiraFields;

  AppJiraConfig(
    this.project,
    this.packageName,
    this.dependPackages,
    this.jiraFields,
  );
}




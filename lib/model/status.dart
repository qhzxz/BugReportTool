enum Status {
  JIRA_SAVED(3),
  JIRA_CREATED(4),
  JIRA_ATTACHMENTS_UPLOADED(6);

  final int code;

  const Status(this.code);
}

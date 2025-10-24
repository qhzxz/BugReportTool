import 'package:bug_report_tool/model/status.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

Widget TicketCard({
  required BuildContext context,
  String? ticketId,
  required int createTime,
  required String ticketTitle,
  required Status status,
  GestureTapCallback? callback,
  String? urlStr,
}) {
  // 需要定义MaterialTheme的颜色方案和字体
  return Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧Ticket信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  if (urlStr != null && urlStr.isNotEmpty) {
                    final Uri url = Uri.parse(urlStr);
                    await launchUrl(url);
                  }
                },
                child: Text(
                  ticketId ?? "",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ), // SemiBold
                ),
              ),
              Text(
                _getTimeFormatString(createTime),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          // 标题文本
          Text(
            ticketTitle,
            style: TextStyle(
              fontWeight: FontWeight.w600, // SemiBold
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          // 右侧操作和状态图标
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (status == Status.JIRA_SAVED || status == Status.JIRA_CREATED)
                ElevatedButton(
                  onPressed: callback,
                  child: Text("重试"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    // 背景色
                    foregroundColor: Colors.white,
                    // 字体颜色
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // 圆角半径
                    ),
                    elevation: 4,
                    // 阴影
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ), // 内边距
                  ),
                ),
              SizedBox(width: 16), // 可以根据间距要求调整
              Text(_getTextByStatus(status)),
            ],
          ),
        ],
      ),
    ),
  );
}

String _getTimeFormatString(int timestamp) {
  final now = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final formatter = DateFormat('yyyy-MM-dd HH:mm');
  return formatter.format(now);
}

String _getTextByStatus(Status s) {
  switch (s) {
    case Status.JIRA_SAVED:
      return "已存储";
    case Status.JIRA_CREATED:
      return '已创建';
    case Status.JIRA_ATTACHMENTS_UPLOADED:
      return '已上传';
  }
}

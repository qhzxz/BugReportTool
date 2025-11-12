import 'dart:io';
import 'package:bug_report_tool/repository/resp/create_ticket_resp.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path/path.dart' as p show basename;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

import '../util/util.dart';

class JiraRestRepository {

  const JiraRestRepository();

  static const String BASE_URL = "https://vivid.jtmap.cn/core/";
  static const String CREATE_TICKET_URL = BASE_URL + "api/v1/sys/jira/issue";
  static const String UPLOAD_FILE_URL = BASE_URL + "api/v1/sys/jira/issue";
  static const Map<String, String> CREATE_TICKET_HEADERS = {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  };
  static const Map<String, String> UPLOAD_FILES_HEADERS = {
    'Accept': 'application/json',
    'X-Atlassian-Token': 'no-check'
  };

  Future<CreateTicketResp?> createTicket(String jsonParam) async {
    Map<String, String> headers = {};
    headers.addAll(CREATE_TICKET_HEADERS);
    final array = utf8.encode(jsonParam);
    headers['Content-Length'] = array.length.toString();
    try {
      final resp = await http.post(
          Uri.parse(CREATE_TICKET_URL), headers: headers,
          body: array);
      if (resp.statusCode == HttpStatus.ok) {
        var decode = json.decode(utf8.decode(resp.bodyBytes));
        logInfo("上报BUG成功:${resp.statusCode},${resp.body}");
        return CreateTicketResp.fromJson(decode);
      }else {
        logInfo("上报BUG失败 code:${resp.statusCode}");
      }
    } catch (e) {
      logInfo("上报BUG失败:$e");
    }
    return null;
  }


  Future<bool> addAttachments(String ticketId,
      List<String> filePathList) async {
    Map<String, String> headers = {};
    headers.addAll(UPLOAD_FILES_HEADERS);
    var request = http.MultipartRequest(
        'POST', Uri.parse("$UPLOAD_FILE_URL/$ticketId/attachments"));
    logInfo("添加上传文件filePathList:${filePathList}");
    for (var filePath in filePathList) {
      if (File(filePath).existsSync()) {
        var type = lookupMimeType(filePath);
        logInfo("添加上传文件:${filePath}");
        request.files.add(await http.MultipartFile.fromPath('file', filePath,
            contentType: type == null ? null : MediaType.parse(type),
            filename: p.basename(filePath)));
      }
    }
    request.headers.addAll(headers);
    StreamedResponse response = await request.send();
    if (response.statusCode == HttpStatus.ok) {
      logInfo("上传文件结果:${await response.stream.bytesToString()}");
      return true;
    }
    return false;
  }

}
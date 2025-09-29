import 'dart:io';
import 'package:bug_report_tool/model/ticket.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JiraTicketRepository {

  static const String BASE_URL = "https://vivid.jtmap.cn/core/";
  static const String CREATE_TICKET_URL = BASE_URL + "api/v1/sys/jira/issue";
  static const Map<String, String> CREATE_TICKET_HEADERS = {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  };

  Future<Ticket?> createTicket(String jsonParam) async {
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
        print("上报BUG成功:${resp.statusCode}");
        return Ticket.fromJson(decode);
      }else {
        print("上报BUG失败 code:${resp.statusCode}");
      }
    } catch (e) {
      print("上报BUG失败:$e");
    }
    return null;
  }
}
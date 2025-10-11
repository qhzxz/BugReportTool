import 'package:bug_report_tool/model/ticket.dart';

class HistoryViewModel {
  final List<Ticket> _historyTicket = [];

  void updateHistory(List<Ticket> list) {
    _historyTicket.clear();
    _historyTicket.addAll(list);
  }

  List<Ticket> getHistory() {
    return List.unmodifiable(_historyTicket);
  }
}
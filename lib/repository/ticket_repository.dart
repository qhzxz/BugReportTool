import 'package:bug_report_tool/database/dao/ticket_dao.dart';
import 'package:bug_report_tool/database/entity/ticket_entity.dart';
import 'package:bug_report_tool/model/ticket.dart';

class TicketRepository {
  final TicketDao _dao;

  TicketRepository(this._dao);

  Future<List<Ticket>> getAll() async {
    var list = await _dao.get();
    return list.map((e) => toTicket(e)).toList();
  }

  Future<bool> saveTicket(Ticket ticket) async {
    return await _dao.insert(ticket.toEntity()) != 0;
  }

  Future<bool> updateTicket(Ticket ticket) async {
    return await _dao.update(ticket.toEntity());
  }
}

import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
part 'ticket.g.dart';

@JsonSerializable()
class Ticket {
  String? key;

  Map<String, String>? errors;

  Ticket(this.key, this.errors);

  /// 由生成的代码实现
  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);

  /// 由生成的代码实现
  Map<String, dynamic> toJson() => _$TicketToJson(this);
}

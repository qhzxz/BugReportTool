import 'dart:core';
import 'package:json_annotation/json_annotation.dart';
part 'create_ticket_resp.g.dart';



@JsonSerializable()
class CreateTicketResp {
  final String? key;

  final Map<String, String>? errors;

  CreateTicketResp(this.key, this.errors);

  /// 由生成的代码实现
  factory CreateTicketResp.fromJson(Map<String, dynamic> json) => _$CreateTicketRespFromJson(json);

  /// 由生成的代码实现
  Map<String, dynamic> toJson() => _$CreateTicketRespToJson(this);
}

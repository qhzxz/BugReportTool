// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_ticket_resp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateTicketResp _$CreateTicketRespFromJson(Map<String, dynamic> json) =>
    CreateTicketResp(
      json['key'] as String?,
      (json['errors'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
    );

Map<String, dynamic> _$CreateTicketRespToJson(CreateTicketResp instance) =>
    <String, dynamic>{'key': instance.key, 'errors': instance.errors};

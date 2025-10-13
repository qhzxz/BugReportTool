// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Setting _$SettingFromJson(Map<String, dynamic> json) => Setting(
  enableVoiceRecording: json['enableVoiceRecording'] as bool?,
  reporterEmail: json['reporterEmail'] as String?,
);

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
  'enableVoiceRecording': instance.enableVoiceRecording,
  'reporterEmail': instance.reporterEmail,
};

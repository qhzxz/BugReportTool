
import 'package:json_annotation/json_annotation.dart';
part 'setting.g.dart';

@JsonSerializable()
class Setting {
  final bool enableVoiceRecording;
  final String reporterEmail;

  Setting({ bool? enableVoiceRecording,
    String? reporterEmail})
      :enableVoiceRecording=enableVoiceRecording ?? false,
        reporterEmail=reporterEmail ?? "";

  copy({ bool? enable,
    String? email}) =>
      Setting(enableVoiceRecording: enable ?? enableVoiceRecording,
          reporterEmail: email ?? reporterEmail);

  /// 由生成的代码实现
  factory Setting.fromJson(Map<String, dynamic> json) =>
      _$SettingFromJson(json);

  /// 由生成的代码实现
  Map<String, dynamic> toJson() => _$SettingToJson(this);
}
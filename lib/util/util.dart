import 'dart:io';

import 'package:intl/intl.dart';

void let<T>(T? value, void Function(T) func) {
  if (value != null) func(value);
}


T? apply<T>(T? value, T Function(T) func) {
  if (value != null) return func(value);
}

T getOrDefault<T>(dynamic map, String key, T defaultValue) {
  if (map[key] != null) return map[key];
  return defaultValue;
}

String getCurrentTimeFormatString() {
  final now = DateTime.now();
  // 使用 intl 包的 DateFormat
  final formatter = DateFormat('yyyyMMDDHHmmss');
  return formatter.format(now);
}



Future<ProcessResult> runCmd(String execute, List<String> arguments) async {
  try {
    return await Process.run(execute, arguments);
  } catch (e) {
    print("执行[$execute,$arguments]异常:$e");
    rethrow;
  }
}
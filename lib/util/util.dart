import 'dart:io';

void let<T>(T? value, void Function(T) func) {
  if (value != null) func(value);
}


T? apply<T>(T? value, T Function(T) func) {
  if (value != null) return func(value);
}


Future<ProcessResult> runCmd(String execute, List<String> arguments) async {
  try {
    return await Process.run(execute, arguments);
  } catch (e) {
    print("执行[$execute,$arguments]异常:$e");
    rethrow;
  }
}
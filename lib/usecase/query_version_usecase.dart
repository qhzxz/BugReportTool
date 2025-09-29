import 'package:flutter/foundation.dart';

import '../util/util.dart';

Future<Map<String, String>> QueryVersionUseCase(String serial,
    List<String> packages) async {
  return compute(_QueryVersionUseCase, _Param(serial, packages));
}

Future<Map<String, String>> _QueryVersionUseCase(_Param p) async {
  Map<String, String> result = {};
  for (var package in p.packages) {
    final runResult = await runCmd(
        'adb', ['-s', p.serial, 'shell', 'dumpsys package $package']);
    if (runResult.exitCode == 0) {
      RegExp reg = RegExp(r'versionName=([^\s]+)');
      Match? match = reg.firstMatch(runResult.stdout);
      let(match, (m) {
        let(m.group(1), (s) => result[package] = s);
      });
    }
  }
  return result;
}

class _Param {
  String serial;
  List<String> packages;

  _Param(this.serial, this.packages);


}
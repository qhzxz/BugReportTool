
import 'dart:core';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

import '../util/util.dart';

Future<List<String>> ListDeviceUseCase() async {
  print("ListDeviceUseCase1 ${Isolate.current.debugName}");
  return compute(_ListDeviceUseCase, _Context());
}

Future<List<String>> _ListDeviceUseCase(_Context c ) async{
  print("ListDeviceUseCase2 ${Isolate.current.debugName}");
  final result = await runCmd('adb', ['devices']);
  final List<String> serials = [];
  if (result.exitCode == 0) {
    final output = result.stdout as String;
    final lines = output.trim().split('\n');

    // 第一行通常是 “List of devices attached”，从第二行开始才是设备信息

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final parts = line.split(RegExp(r'\s+'));
      if (parts.isNotEmpty && parts[0] != 'daemon' && parts[0] != 'offline') {
        serials.add(parts[0]);
      }
    }
  }
  return serials;
}

 class _Context{}
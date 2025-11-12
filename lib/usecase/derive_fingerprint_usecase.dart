import 'dart:io';

import 'package:flutter/foundation.dart';

import '../util/util.dart';

Future<String> DeriveFingerprintUsecase(String serial) async {
  return compute(_DeriveFingerprintUsecase, _Context(serial));
}

Future<String> _DeriveFingerprintUsecase(_Context context) async {
  String? finger = await getProp(context.serial, "ro.build.fingerprint");
  if (finger != null && finger.isNotEmpty) {
    return finger;
  } else {
    // 为空时按规则拼接
    String? brand = await getProp(context.serial, "ro.product.brand");
    String? name = await getProp(context.serial, "ro.product.name");
    String? device = await getProp(context.serial, "ro.product.device");
    String? release = await getProp(context.serial, "ro.build.version.release");
    String? buildId = await getProp(context.serial, "ro.build.id");
    String? incremental = await getProp(context.serial, "ro.build.version.incremental");
    String? type = await getProp(context.serial, "ro.build.type");
    String? tags = await getProp(context.serial, "ro.build.tags");

    String info =
        "${brand ?? ''}/${name ?? ''}/${device ?? ''}:"
        "${release ?? ''}/${buildId ?? ''}/${incremental ?? ''}:"
        "${type ?? ''}/${tags ?? ''}";
    logInfo("system info :$info");
    return info;
  }
}

Future<String?> getProp(String serial, String key) async {
  // 获取系统属性
  ProcessResult result = await runCmd('adb', [
    '-s',
    serial,
    'shell',
    'getprop',
    key,
  ]);
  String value = result.stdout.toString().trim();
  return value.isNotEmpty ? value : null;
}

class _Context{
  String serial;

  _Context(this.serial);
}
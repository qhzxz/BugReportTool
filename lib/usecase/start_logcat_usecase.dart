import 'dart:isolate';

import 'package:bug_report_tool/logcat/logcat.dart';
import 'package:bug_report_tool/model/result.dart';
import 'package:bug_report_tool/usecase/usecase.dart';
import 'package:flutter/foundation.dart';

import '../util/util.dart';

class StartLogcatUsecase extends UseCase<bool> {
  String _serial;

  StartLogcatUsecase(this._serial);

  @override
  Future<Result<bool>> run() async {
    final instance = await Logcat.getInstance();
    String? path = await instance.startCapturing(_serial);
    return Success(path != null);
  }
}

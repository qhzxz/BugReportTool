
import 'package:bug_report_tool/model/result.dart';
import 'package:flutter/widgets.dart';

abstract class UseCase<R> {
  Future<Result<R>> execute() async {
    try {
      return await run();
    } catch (e) {
      return Error(exception: e);
    }
  }

  @protected
  Future<Result<R>> run();
}

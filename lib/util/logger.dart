import 'dart:io';

import 'package:logger/logger.dart';

class BugReportLogger {

  static void init(String logFilePath) {
    logger = Logger(output: MultiOutput([
      ConsoleOutput(),
      FileOutput(file: File('$logFilePath${Platform.pathSeparator}app.log')),
    ]));
  }
  static late Logger logger;

  static void logInfo(String message){
    logger.i(message);
  }
}
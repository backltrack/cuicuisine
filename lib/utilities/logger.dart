import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

export 'package:logging/logging.dart' show Logger, Level;

void setupLogging() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
  Logger.root.onRecord.listen((record) {
    final msg = '[${record.level.name}] ${record.loggerName}: ${record.message}';
    final err = record.error != null ? '\n  ${record.error}' : '';
    final stack = record.stackTrace != null ? '\n  ${record.stackTrace}' : '';
    // ignore: avoid_print
    print('$msg$err$stack');
  });
}

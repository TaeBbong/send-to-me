import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Appends diagnostic lines to an on-device log file so issues can be inspected
/// later — even after the app was closed and the device disconnected — by
/// pulling the file over adb:
///
///   adb pull /sdcard/Android/data/{applicationId}/files/diagnostic.log
///
/// Also mirrors every line to `debugPrint` (logcat `flutter` tag) when attached.
/// Writes are serialized and best-effort: any IO error is swallowed so logging
/// never affects app behavior.
class DiagnosticLog {
  DiagnosticLog._();

  static final DiagnosticLog instance = DiagnosticLog._();

  static const String _fileName = 'diagnostic.log';
  static const int _maxBytes = 512 * 1024; // rotate (keep tail) past 512 KB

  File? _file;
  Future<void> _queue = Future<void>.value();

  /// Records [message] with a timestamp. Fire-and-forget.
  void log(String message) {
    final line = '${DateTime.now().toIso8601String()} $message';
    debugPrint(line);
    _queue = _queue.then((_) => _append(line)).catchError((_) {});
  }

  Future<void> _append(String line) async {
    final file = await _resolveFile();
    if (file == null) return;

    // Keep the file from growing unbounded: when it gets large, retain the tail.
    try {
      if (await file.exists() && await file.length() > _maxBytes) {
        final content = await file.readAsString();
        await file.writeAsString(content.substring(content.length - _maxBytes ~/ 2));
      }
    } catch (_) {
      // ignore rotation failures
    }

    await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
  }

  Future<File?> _resolveFile() async {
    if (_file != null) return _file;
    try {
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory(); // .../Android/data/<pkg>/files
      }
      dir ??= await getApplicationDocumentsDirectory();
      return _file = File('${dir.path}/$_fileName');
    } catch (_) {
      return null;
    }
  }
}

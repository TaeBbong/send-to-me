// Driver entrypoint used only to capture App Store / Play screenshots.
// It enables the Flutter driver extension (so an external tool can tap and
// scroll the real app) and then defers to the normal `main()`. Not shipped.
import 'package:flutter_driver/driver_extension.dart';

import 'main.dart' as app;

Future<void> main() async {
  enableFlutterDriverExtension();
  await app.main();
}

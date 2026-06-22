import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'classification_service.dart';
import 'classification_worker.dart';

final classificationServiceProvider = Provider<ClassificationService>(
  (ref) => const ClassificationService(),
);

final classificationWorkerProvider = Provider<ClassificationWorker>((ref) {
  final worker = ClassificationWorker(ref);
  ref.onDispose(worker.dispose);
  return worker;
});

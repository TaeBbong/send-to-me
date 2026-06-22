import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live progress of a "re-classify drafts" run, surfaced in the draft room so
/// the user can see it working and learn how many memos were moved.
class ReclassifyStatus {
  const ReclassifyStatus({
    this.running = false,
    this.total = 0,
    this.done = 0,
    this.moved = 0,
    this.inFlight = const {},
  });

  final bool running;
  final int total;
  final int done;
  final int moved;

  /// Ids of memos currently being re-classified.
  final Set<String> inFlight;

  ReclassifyStatus copyWith({
    bool? running,
    int? total,
    int? done,
    int? moved,
    Set<String>? inFlight,
  }) {
    return ReclassifyStatus(
      running: running ?? this.running,
      total: total ?? this.total,
      done: done ?? this.done,
      moved: moved ?? this.moved,
      inFlight: inFlight ?? this.inFlight,
    );
  }
}

class ReclassifyStatusNotifier extends Notifier<ReclassifyStatus> {
  @override
  ReclassifyStatus build() => const ReclassifyStatus();

  void start(int total) => state = ReclassifyStatus(running: true, total: total);

  void begin(String id) =>
      state = state.copyWith(inFlight: {...state.inFlight, id});

  void finish(String id, {required bool moved}) {
    state = state.copyWith(
      inFlight: state.inFlight.where((e) => e != id).toSet(),
      done: state.done + 1,
      moved: state.moved + (moved ? 1 : 0),
    );
  }

  void complete() => state = state.copyWith(running: false, inFlight: const {});
}

final reclassifyStatusProvider =
    NotifierProvider<ReclassifyStatusNotifier, ReclassifyStatus>(
  ReclassifyStatusNotifier.new,
);

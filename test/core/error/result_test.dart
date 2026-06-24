import 'package:awesome_memo/core/error/failure.dart';
import 'package:awesome_memo/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result.ok', () {
    const result = Result<int>.ok(42);

    test('is Ok, not Err', () {
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
    });

    test('exposes the value and a null failure', () {
      expect(result.valueOrNull, 42);
      expect(result.failureOrNull, isNull);
    });

    test('when() runs the ok branch', () {
      final out = result.when(ok: (v) => 'ok:$v', err: (_) => 'err');
      expect(out, 'ok:42');
    });

    test('map() transforms the value', () {
      final mapped = result.map((v) => v * 2);
      expect(mapped.valueOrNull, 84);
    });
  });

  group('Result.err', () {
    const failure = StorageFailure('boom');
    const Result<int> result = Result<int>.err(failure);

    test('is Err, not Ok', () {
      expect(result.isErr, isTrue);
      expect(result.isOk, isFalse);
    });

    test('exposes the failure and a null value', () {
      expect(result.failureOrNull, failure);
      expect(result.valueOrNull, isNull);
    });

    test('when() runs the err branch', () {
      final out = result.when(ok: (_) => 'ok', err: (f) => 'err:${f.message}');
      expect(out, 'err:boom');
    });

    test('map() preserves the failure and does not call the transform', () {
      var called = false;
      final mapped = result.map((v) {
        called = true;
        return v * 2;
      });
      expect(called, isFalse);
      expect(mapped.failureOrNull, failure);
    });
  });
}

import 'package:dartllm/src/models/enums.dart';
import 'package:test/test.dart';

void main() {
  group('MessageRole', () {
    test('has three values', () {
      expect(MessageRole.values, hasLength(3));
    });

    test('contains system role', () {
      expect(MessageRole.values, contains(MessageRole.system));
    });

    test('contains user role', () {
      expect(MessageRole.values, contains(MessageRole.user));
    });

    test('contains assistant role', () {
      expect(MessageRole.values, contains(MessageRole.assistant));
    });

    test('values are in expected order', () {
      expect(MessageRole.values[0], equals(MessageRole.system));
      expect(MessageRole.values[1], equals(MessageRole.user));
      expect(MessageRole.values[2], equals(MessageRole.assistant));
    });
  });

  group('FinishReason', () {
    test('has three values', () {
      expect(FinishReason.values, hasLength(3));
    });

    test('contains length reason', () {
      expect(FinishReason.values, contains(FinishReason.length));
    });

    test('contains stop reason', () {
      expect(FinishReason.values, contains(FinishReason.stop));
    });

    test('contains error reason', () {
      expect(FinishReason.values, contains(FinishReason.error));
    });
  });

  group('KVCacheType', () {
    test('has three values', () {
      expect(KVCacheType.values, hasLength(3));
    });

    test('contains f16 type', () {
      expect(KVCacheType.values, contains(KVCacheType.f16));
    });

    test('contains q8_0 type', () {
      expect(KVCacheType.values, contains(KVCacheType.q8_0));
    });

    test('contains q4_0 type', () {
      expect(KVCacheType.values, contains(KVCacheType.q4_0));
    });

    test('f16 has highest precision', () {
      expect(KVCacheType.f16.index, equals(0));
    });
  });

  group('LogLevel', () {
    test('has four values', () {
      expect(LogLevel.values, hasLength(4));
    });

    test('contains error level', () {
      expect(LogLevel.values, contains(LogLevel.error));
    });

    test('contains warning level', () {
      expect(LogLevel.values, contains(LogLevel.warning));
    });

    test('contains info level', () {
      expect(LogLevel.values, contains(LogLevel.info));
    });

    test('contains debug level', () {
      expect(LogLevel.values, contains(LogLevel.debug));
    });

    test('levels are ordered by verbosity', () {
      expect(LogLevel.error.index, lessThan(LogLevel.warning.index));
      expect(LogLevel.warning.index, lessThan(LogLevel.info.index));
      expect(LogLevel.info.index, lessThan(LogLevel.debug.index));
    });
  });
}

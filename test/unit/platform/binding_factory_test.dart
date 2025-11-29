import 'package:dartllm/src/platform/binding_factory.dart';
import 'package:test/test.dart';

void main() {
  group('BindingFactory', () {
    tearDown(() {
      BindingFactory.resetForTesting();
    });

    test('instance is null before create', () {
      expect(BindingFactory.instance, isNull);
    });

    test('resetForTesting clears instance', () async {
      // Try to create (may fail if native library not available)
      try {
        await BindingFactory.create();
      } on Exception {
        // Expected if native library not bundled
      }

      BindingFactory.resetForTesting();
      expect(BindingFactory.instance, isNull);
    });

    test('dispose clears instance', () async {
      // Try to create (may fail if native library not available)
      try {
        await BindingFactory.create();
      } on Exception {
        // Expected if native library not bundled
      }

      BindingFactory.dispose();
      expect(BindingFactory.instance, isNull);
    });

    test('create returns binding when native library available', () async {
      // This test only passes when the native library is built
      final binding = await BindingFactory.create();
      expect(binding, isNotNull);
      expect(BindingFactory.instance, isNotNull);
    });
  });
}

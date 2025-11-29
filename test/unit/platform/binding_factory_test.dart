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

    test('create throws when native library not available', () async {
      // On a test environment without the native library,
      // create should throw an exception
      expect(
        () => BindingFactory.create(),
        throwsException,
      );
    });
  });
}

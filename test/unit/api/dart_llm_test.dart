import 'dart:io';

import 'package:dartllm/src/api/dart_llm.dart';
import 'package:dartllm/src/models/enums.dart';
import 'package:dartllm/src/models/global_config.dart';
import 'package:test/test.dart';

void main() {
  group('DartLLM', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('dartllm_test_');
      DartLLM.setGlobalConfig(GlobalConfig(
        defaultCacheDirectory: tempDir.path,
      ));
    });

    tearDownAll(() async {
      DartLLM.dispose();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('globalConfig', () {
      test('has default configuration', () {
        // Reset to check defaults
        final defaultConfig = const GlobalConfig();

        expect(defaultConfig.enableLogging, isFalse);
        expect(defaultConfig.logLevel, equals(LogLevel.warning));
      });

      test('setGlobalConfig updates configuration', () {
        final newConfig = GlobalConfig(
          enableLogging: true,
          logLevel: LogLevel.debug,
          defaultGpuLayers: 32,
          defaultCacheDirectory: tempDir.path,
        );

        DartLLM.setGlobalConfig(newConfig);

        expect(DartLLM.globalConfig.enableLogging, isTrue);
        expect(DartLLM.globalConfig.logLevel, equals(LogLevel.debug));
        expect(DartLLM.globalConfig.defaultGpuLayers, equals(32));

        // Reset to test config
        DartLLM.setGlobalConfig(GlobalConfig(
          defaultCacheDirectory: tempDir.path,
        ));
      });
    });

    group('version', () {
      test('returns version string', () {
        expect(DartLLM.version, isNotEmpty);
        expect(DartLLM.version, matches(RegExp(r'^\d+\.\d+\.\d+')));
      });
    });

    group('llamaCppVersion', () {
      test('returns null when native library not available', () {
        expect(DartLLM.llamaCppVersion, isNull);
      });
    });

    group('isPlatformSupported', () {
      test('returns boolean', () {
        expect(DartLLM.isPlatformSupported, isA<bool>());
      });
    });

    group('listCachedModels', () {
      test('returns empty list when no models cached', () async {
        final cached = await DartLLM.listCachedModels();

        expect(cached, isEmpty);
      });
    });

    group('clearCache', () {
      test('returns 0 when cache is empty', () async {
        final freed = await DartLLM.clearCache();

        expect(freed, equals(0));
      });

      test('accepts optional modelId', () async {
        final freed = await DartLLM.clearCache(modelId: 'some-model');

        expect(freed, equals(0));
      });
    });

    group('getCacheSize', () {
      test('returns 0 when cache is empty', () async {
        final size = await DartLLM.getCacheSize();

        expect(size, equals(0));
      });
    });

    group('getCachedModelCount', () {
      test('returns 0 when cache is empty', () async {
        final count = await DartLLM.getCachedModelCount();

        expect(count, equals(0));
      });
    });

    group('loadFromHuggingFace', () {
      test('throws exception for invalid repository', () async {
        expect(
          () => DartLLM.loadFromHuggingFace(
            'invalid-repo-that-does-not-exist-12345',
            filename: 'model.gguf',
          ),
          throwsA(anything),
        );
      });
    });

    group('loadFromUrl', () {
      test('throws exception for invalid URL', () async {
        expect(
          () => DartLLM.loadFromUrl(
            'https://invalid-host-that-does-not-exist-12345.example.com/model.gguf',
          ),
          throwsA(anything),
        );
      });
    });

    group('loadModel', () {
      test('throws when model file does not exist', () async {
        expect(
          () => DartLLM.loadModel('/nonexistent/path/model.gguf'),
          throwsA(anything),
        );
      });
    });

    group('getModelInfo', () {
      test('throws when model file does not exist', () async {
        expect(
          () => DartLLM.getModelInfo('/nonexistent/path/model.gguf'),
          throwsA(anything),
        );
      });
    });

    group('dispose', () {
      test('can be called safely', () {
        DartLLM.dispose();
        DartLLM.dispose();

        expect(true, isTrue);
      });
    });
  });
}

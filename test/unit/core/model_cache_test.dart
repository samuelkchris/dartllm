import 'dart:io';

import 'package:dartllm/src/core/model_cache.dart';
import 'package:dartllm/src/models/model_info.dart';
import 'package:test/test.dart';

void main() {
  group('ModelCache', () {
    late Directory tempDir;
    late ModelCache cache;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('dartllm_cache_test_');
      cache = ModelCache(cacheDirectory: tempDir.path);
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('initialization', () {
      test('isInitialized returns false before initialization', () {
        expect(cache.isInitialized, isFalse);
      });

      test('initialize creates cache directory', () async {
        await cache.initialize();

        expect(cache.isInitialized, isTrue);
        expect(await Directory(cache.cacheDirectory).exists(), isTrue);
      });

      test('initialize is idempotent', () async {
        await cache.initialize();
        await cache.initialize();

        expect(cache.isInitialized, isTrue);
      });

      test('cacheDirectory throws if not initialized', () {
        expect(() => cache.cacheDirectory, throwsStateError);
      });
    });

    group('model operations', () {
      late File testModelFile;

      setUp(() async {
        await cache.initialize();

        testModelFile = File('${tempDir.path}/test_model.gguf');
        await testModelFile.writeAsString('test model content');
      });

      test('listModels returns empty list initially', () async {
        final models = await cache.listModels();

        expect(models, isEmpty);
      });

      test('addModel copies file to cache', () async {
        final info = await cache.addModel(
          'test-model',
          testModelFile.path,
          sourceUrl: 'https://example.com/model.gguf',
        );

        expect(info.modelId, equals('test-model'));
        expect(info.sourceUrl, equals('https://example.com/model.gguf'));
        expect(info.sizeBytes, greaterThan(0));
        expect(await File(info.filePath).exists(), isTrue);
      });

      test('addModel with move removes source file', () async {
        final sourcePath = '${tempDir.path}/model_to_move.gguf';
        await File(sourcePath).writeAsString('content to move');

        await cache.addModel(
          'moved-model',
          sourcePath,
          move: true,
        );

        expect(await File(sourcePath).exists(), isFalse);
      });

      test('hasModel returns true for cached model', () async {
        await cache.addModel('test-model', testModelFile.path);

        expect(await cache.hasModel('test-model'), isTrue);
        expect(await cache.hasModel('nonexistent'), isFalse);
      });

      test('getModel returns cached model info', () async {
        await cache.addModel(
          'test-model',
          testModelFile.path,
          sourceUrl: 'https://example.com/model.gguf',
        );

        final info = await cache.getModel('test-model');

        expect(info, isNotNull);
        expect(info!.modelId, equals('test-model'));
        expect(info.sourceUrl, equals('https://example.com/model.gguf'));
      });

      test('getModel returns null for nonexistent model', () async {
        final info = await cache.getModel('nonexistent');

        expect(info, isNull);
      });

      test('getModelPath returns path for cached model', () async {
        await cache.addModel('test-model', testModelFile.path);

        final path = await cache.getModelPath('test-model');

        expect(path, isNotNull);
        expect(await File(path!).exists(), isTrue);
      });

      test('removeModel deletes file and metadata', () async {
        await cache.addModel('test-model', testModelFile.path);
        final info = await cache.getModel('test-model');

        final freed = await cache.removeModel('test-model');

        expect(freed, greaterThan(0));
        expect(await cache.hasModel('test-model'), isFalse);
        expect(await File(info!.filePath).exists(), isFalse);
      });

      test('removeModel returns 0 for nonexistent model', () async {
        final freed = await cache.removeModel('nonexistent');

        expect(freed, equals(0));
      });

      test('clear removes all models', () async {
        await cache.addModel('model1', testModelFile.path);

        final model2File = File('${tempDir.path}/model2.gguf');
        await model2File.writeAsString('model 2 content');
        await cache.addModel('model2', model2File.path);

        final freed = await cache.clear();

        expect(freed, greaterThan(0));
        expect(await cache.listModels(), isEmpty);
      });

      test('totalSize returns sum of all model sizes', () async {
        await cache.addModel('model1', testModelFile.path);

        final model2File = File('${tempDir.path}/model2.gguf');
        await model2File.writeAsString('model 2 longer content');
        await cache.addModel('model2', model2File.path);

        final size = await cache.totalSize();

        expect(size, greaterThan(0));
      });

      test('modelCount returns number of cached models', () async {
        expect(await cache.modelCount(), equals(0));

        await cache.addModel('model1', testModelFile.path);
        expect(await cache.modelCount(), equals(1));

        final model2File = File('${tempDir.path}/model2.gguf');
        await model2File.writeAsString('model 2');
        await cache.addModel('model2', model2File.path);
        expect(await cache.modelCount(), equals(2));
      });

      test('verifyModel returns true for valid cached model', () async {
        await cache.addModel('test-model', testModelFile.path);

        expect(await cache.verifyModel('test-model'), isTrue);
      });

      test('verifyModel returns false for nonexistent model', () async {
        expect(await cache.verifyModel('nonexistent'), isFalse);
      });

      test('verifyModel returns false if file was deleted', () async {
        final info = await cache.addModel('test-model', testModelFile.path);
        await File(info.filePath).delete();

        expect(await cache.verifyModel('test-model'), isFalse);
      });
    });

    group('model ID sanitization', () {
      late File testModelFile;

      setUp(() async {
        await cache.initialize();
        testModelFile = File('${tempDir.path}/test.gguf');
        await testModelFile.writeAsString('test');
      });

      test('sanitizes slashes in model ID', () async {
        final info = await cache.addModel(
          'org/repo/model.gguf',
          testModelFile.path,
        );

        expect(info.filePath.contains('/'), isTrue);
        expect(await cache.hasModel('org/repo/model.gguf'), isTrue);
      });

      test('sanitizes special characters in model ID', () async {
        await cache.addModel(
          'model:v1?q=test*<>|"name',
          testModelFile.path,
        );

        expect(await cache.hasModel('model:v1?q=test*<>|"name'), isTrue);
      });
    });

    group('error handling', () {
      setUp(() async {
        await cache.initialize();
      });

      test('addModel throws for nonexistent source file', () async {
        expect(
          () => cache.addModel('model', '/nonexistent/path.gguf'),
          throwsArgumentError,
        );
      });

      test('methods throw if not initialized', () async {
        final uninitializedCache = ModelCache(cacheDirectory: tempDir.path);

        expect(() => uninitializedCache.listModels(), throwsStateError);
        expect(() => uninitializedCache.hasModel('x'), throwsStateError);
      });
    });
  });

  group('CachedModelInfo', () {
    test('sizeFormatted returns human readable size', () {
      final smallModel = CachedModelInfo(
        modelId: 'small',
        filePath: '/path/small.gguf',
        sizeBytes: 500 * 1024 * 1024,
        downloadedAt: DateTime.now(),
        sourceUrl: 'https://example.com/small.gguf',
      );

      expect(smallModel.sizeFormatted, contains('MB'));

      final largeModel = CachedModelInfo(
        modelId: 'large',
        filePath: '/path/large.gguf',
        sizeBytes: 5 * 1024 * 1024 * 1024,
        downloadedAt: DateTime.now(),
        sourceUrl: 'https://example.com/large.gguf',
      );

      expect(largeModel.sizeFormatted, contains('GB'));
    });
  });
}

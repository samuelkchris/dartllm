import 'package:dartllm/src/core/huggingface_client.dart';
import 'package:test/test.dart';

void main() {
  group('HuggingFaceFile', () {
    test('sizeMB converts bytes to megabytes', () {
      const file = HuggingFaceFile(
        filename: 'model.gguf',
        sizeBytes: 100 * 1024 * 1024,
      );

      expect(file.sizeMB, equals(100.0));
    });

    test('sizeGB converts bytes to gigabytes', () {
      const file = HuggingFaceFile(
        filename: 'model.gguf',
        sizeBytes: 5 * 1024 * 1024 * 1024,
      );

      expect(file.sizeGB, equals(5.0));
    });

    test('toString includes filename and size', () {
      const file = HuggingFaceFile(
        filename: 'model.gguf',
        sizeBytes: 100 * 1024 * 1024,
      );

      expect(file.toString(), contains('model.gguf'));
      expect(file.toString(), contains('100.0 MB'));
    });

    test('creates file with all properties', () {
      const file = HuggingFaceFile(
        filename: 'model.gguf',
        sizeBytes: 1000,
        blobId: 'abc123',
        isLfs: true,
      );

      expect(file.filename, equals('model.gguf'));
      expect(file.sizeBytes, equals(1000));
      expect(file.blobId, equals('abc123'));
      expect(file.isLfs, isTrue);
    });

    test('defaults isLfs to false', () {
      const file = HuggingFaceFile(
        filename: 'model.gguf',
        sizeBytes: 1000,
      );

      expect(file.isLfs, isFalse);
    });
  });

  group('HuggingFaceRepo', () {
    test('ggufFiles filters only GGUF files', () {
      const repo = HuggingFaceRepo(
        repoId: 'author/model',
        author: 'author',
        files: [
          HuggingFaceFile(filename: 'model.gguf', sizeBytes: 1000),
          HuggingFaceFile(filename: 'readme.md', sizeBytes: 100),
          HuggingFaceFile(filename: 'model.q4.gguf', sizeBytes: 2000),
          HuggingFaceFile(filename: 'config.json', sizeBytes: 50),
        ],
      );

      final ggufFiles = repo.ggufFiles;

      expect(ggufFiles, hasLength(2));
      expect(ggufFiles.map((f) => f.filename), contains('model.gguf'));
      expect(ggufFiles.map((f) => f.filename), contains('model.q4.gguf'));
    });

    test('ggufFiles is case insensitive', () {
      const repo = HuggingFaceRepo(
        repoId: 'author/model',
        author: 'author',
        files: [
          HuggingFaceFile(filename: 'model.GGUF', sizeBytes: 1000),
          HuggingFaceFile(filename: 'other.GgUf', sizeBytes: 2000),
        ],
      );

      expect(repo.ggufFiles, hasLength(2));
    });

    test('toString includes repoId and file count', () {
      const repo = HuggingFaceRepo(
        repoId: 'author/model',
        author: 'author',
        files: [
          HuggingFaceFile(filename: 'model.gguf', sizeBytes: 1000),
          HuggingFaceFile(filename: 'readme.md', sizeBytes: 100),
        ],
      );

      expect(repo.toString(), contains('author/model'));
      expect(repo.toString(), contains('2 files'));
    });

    test('defaults branch to main', () {
      const repo = HuggingFaceRepo(
        repoId: 'author/model',
        author: 'author',
        files: [],
      );

      expect(repo.branch, equals('main'));
    });
  });

  group('HuggingFaceClient', () {
    late HuggingFaceClient client;

    setUp(() {
      client = HuggingFaceClient();
    });

    tearDown(() {
      client.close();
    });

    test('creates client without token', () {
      expect(client, isNotNull);
    });

    test('creates client with token', () {
      final tokenClient = HuggingFaceClient(apiToken: 'test-token');
      expect(tokenClient, isNotNull);
      tokenClient.close();
    });

    test('getDownloadUrl constructs correct URL', () {
      final url = client.getDownloadUrl(
        'TheBloke/Llama-2-7B-GGUF',
        'llama-2-7b.Q4_K_M.gguf',
      );

      expect(
        url,
        equals(
          'https://huggingface.co/TheBloke/Llama-2-7B-GGUF/resolve/main/llama-2-7b.Q4_K_M.gguf',
        ),
      );
    });

    test('getDownloadUrl uses custom branch', () {
      final url = client.getDownloadUrl(
        'TheBloke/Llama-2-7B-GGUF',
        'llama-2-7b.Q4_K_M.gguf',
        branch: 'dev',
      );

      expect(url, contains('/resolve/dev/'));
    });

    test('close can be called multiple times safely', () {
      client.close();
      client.close();

      expect(true, isTrue);
    });
  });
}

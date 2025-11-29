import 'dart:io';

import 'package:dartllm/src/utils/path_utils.dart';
import 'package:dartllm/src/utils/platform_utils.dart';
import 'package:test/test.dart';

void main() {
  group('PathUtils', () {
    group('defaultCacheBaseDir', () {
      test('returns appropriate path for desktop platforms', () {
        final platform = PlatformUtils.current;
        final cacheDir = PathUtils.defaultCacheBaseDir;

        if (platform == DartLLMPlatform.macos) {
          expect(cacheDir, contains('Library/Caches'));
        } else if (platform == DartLLMPlatform.linux) {
          expect(cacheDir, contains('.cache'));
        } else if (platform == DartLLMPlatform.windows) {
          expect(cacheDir, isNotNull);
        }
      });
    });

    group('defaultModelCacheDir', () {
      test('includes dartllm and models subdirectories', () {
        final modelDir = PathUtils.defaultModelCacheDir;

        if (modelDir != null) {
          expect(modelDir, contains(PathUtils.libraryDirName));
          expect(modelDir, contains(PathUtils.modelsDirName));
        }
      });
    });

    group('joinPaths', () {
      test('joins path segments with separator', () {
        final result = PathUtils.joinPaths(['home', 'user', 'models']);

        expect(result, contains('home'));
        expect(result, contains('user'));
        expect(result, contains('models'));
      });

      test('filters out empty segments', () {
        final result = PathUtils.joinPaths(['home', '', 'user', '', 'models']);
        final parts = result.split(Platform.pathSeparator);

        expect(parts, equals(['home', 'user', 'models']));
      });

      test('returns empty string for empty list', () {
        expect(PathUtils.joinPaths([]), isEmpty);
      });
    });

    group('normalizePath', () {
      test('removes redundant separators', () {
        final sep = Platform.pathSeparator;
        final input = '${sep}home$sep${sep}user$sep$sep${sep}models$sep';
        final result = PathUtils.normalizePath(input);

        expect(result, equals('${sep}home${sep}user${sep}models'));
      });

      test('preserves root path', () {
        if (!Platform.isWindows) {
          expect(PathUtils.normalizePath('/'), equals('/'));
        }
      });
    });

    group('expandPath', () {
      test('expands ~ to home directory', () {
        final result = PathUtils.expandPath('~/models');
        final home = Platform.environment['HOME'] ??
            Platform.environment['USERPROFILE'] ??
            '';

        if (home.isNotEmpty) {
          expect(result, startsWith(home));
          expect(result, endsWith('models'));
        }
      });

      test('returns path unchanged if no tilde', () {
        final path = '/absolute/path/to/file';
        expect(PathUtils.expandPath(path), equals(path));
      });

      test('expands lone tilde to home', () {
        final result = PathUtils.expandPath('~');
        final home = Platform.environment['HOME'] ??
            Platform.environment['USERPROFILE'] ??
            '';

        if (home.isNotEmpty) {
          expect(result, equals(home));
        }
      });
    });

    group('getExtension', () {
      test('extracts file extension', () {
        expect(PathUtils.getExtension('/path/to/model.gguf'), equals('gguf'));
        expect(PathUtils.getExtension('file.txt'), equals('txt'));
        expect(PathUtils.getExtension('archive.tar.gz'), equals('gz'));
      });

      test('returns empty string for no extension', () {
        expect(PathUtils.getExtension('/path/to/readme'), isEmpty);
        expect(PathUtils.getExtension('noextension'), isEmpty);
      });

      test('handles hidden files correctly', () {
        expect(PathUtils.getExtension('.gitignore'), equals('gitignore'));
      });
    });

    group('getFilename', () {
      test('extracts filename from path', () {
        final sep = Platform.pathSeparator;
        expect(
          PathUtils.getFilename('${sep}path${sep}to${sep}model.gguf'),
          equals('model.gguf'),
        );
      });

      test('returns input if no separator', () {
        expect(PathUtils.getFilename('model.gguf'), equals('model.gguf'));
      });
    });

    group('getDirectory', () {
      test('extracts directory from path', () {
        final sep = Platform.pathSeparator;
        final path = '${sep}path${sep}to${sep}model.gguf';
        expect(
          PathUtils.getDirectory(path),
          equals('${sep}path${sep}to'),
        );
      });

      test('returns empty string for filename only', () {
        expect(PathUtils.getDirectory('model.gguf'), isEmpty);
      });
    });

    group('isAbsolute', () {
      test('detects Unix absolute paths', () {
        expect(PathUtils.isAbsolute('/home/user'), isTrue);
        expect(PathUtils.isAbsolute('/'), isTrue);
      });

      test('detects Windows absolute paths', () {
        expect(PathUtils.isAbsolute('C:\\Users'), isTrue);
        expect(PathUtils.isAbsolute('D:/folder'), isTrue);
        expect(PathUtils.isAbsolute('\\\\server\\share'), isTrue);
      });

      test('returns false for relative paths', () {
        expect(PathUtils.isAbsolute('relative/path'), isFalse);
        expect(PathUtils.isAbsolute('./local'), isFalse);
        expect(PathUtils.isAbsolute('../parent'), isFalse);
        expect(PathUtils.isAbsolute('file.txt'), isFalse);
      });

      test('returns false for empty string', () {
        expect(PathUtils.isAbsolute(''), isFalse);
      });
    });

    group('getCacheFilename', () {
      test('generates filename with extension from URL', () {
        final filename = PathUtils.getCacheFilename(
          'https://huggingface.co/model.gguf',
        );

        expect(filename, endsWith('.gguf'));
        expect(filename.length, greaterThan(5)); // hash + .gguf
      });

      test('generates filename without extension for extensionless URL', () {
        final filename = PathUtils.getCacheFilename(
          'https://example.com/model',
        );

        expect(filename, isNotEmpty);
        expect(filename.contains('.'), isFalse);
      });

      test('generates consistent filenames for same URL', () {
        const url = 'https://example.com/model.gguf';
        final filename1 = PathUtils.getCacheFilename(url);
        final filename2 = PathUtils.getCacheFilename(url);

        expect(filename1, equals(filename2));
      });

      test('generates different filenames for different URLs', () {
        final filename1 = PathUtils.getCacheFilename(
          'https://example.com/model1.gguf',
        );
        final filename2 = PathUtils.getCacheFilename(
          'https://example.com/model2.gguf',
        );

        expect(filename1, isNot(equals(filename2)));
      });
    });

    group('constants', () {
      test('libraryDirName is dartllm', () {
        expect(PathUtils.libraryDirName, equals('dartllm'));
      });

      test('modelsDirName is models', () {
        expect(PathUtils.modelsDirName, equals('models'));
      });
    });
  });
}

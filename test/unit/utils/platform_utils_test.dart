import 'dart:io';

import 'package:dartllm/src/utils/platform_utils.dart';
import 'package:test/test.dart';

void main() {
  group('PlatformUtils', () {
    group('current', () {
      test('returns a valid platform', () {
        final platform = PlatformUtils.current;

        expect(platform, isA<DartLLMPlatform>());
        expect(platform, isNot(equals(DartLLMPlatform.web)));
      });

      test('matches dart:io Platform', () {
        final platform = PlatformUtils.current;

        if (Platform.isMacOS) {
          expect(platform, equals(DartLLMPlatform.macos));
        } else if (Platform.isWindows) {
          expect(platform, equals(DartLLMPlatform.windows));
        } else if (Platform.isLinux) {
          expect(platform, equals(DartLLMPlatform.linux));
        }
      });
    });

    group('platform categories', () {
      test('isMobile returns correct value', () {
        final isMobile = PlatformUtils.isMobile;
        final platform = PlatformUtils.current;

        if (platform == DartLLMPlatform.android ||
            platform == DartLLMPlatform.ios) {
          expect(isMobile, isTrue);
        } else {
          expect(isMobile, isFalse);
        }
      });

      test('isDesktop returns correct value', () {
        final isDesktop = PlatformUtils.isDesktop;
        final platform = PlatformUtils.current;

        if (platform == DartLLMPlatform.macos ||
            platform == DartLLMPlatform.windows ||
            platform == DartLLMPlatform.linux) {
          expect(isDesktop, isTrue);
        } else {
          expect(isDesktop, isFalse);
        }
      });

      test('isWeb returns false for native platforms', () {
        expect(PlatformUtils.isWeb, isFalse);
      });
    });

    group('feature support', () {
      test('supportsFFI returns true for native platforms', () {
        expect(PlatformUtils.supportsFFI, isTrue);
      });

      test('supportsGpuAcceleration returns true for known platforms', () {
        if (PlatformUtils.current != DartLLMPlatform.unknown) {
          expect(PlatformUtils.supportsGpuAcceleration, isTrue);
        }
      });

      test('supportsMemoryMapping returns true for native platforms', () {
        expect(PlatformUtils.supportsMemoryMapping, isTrue);
      });

      test('supportsMultiThreading returns true for native platforms', () {
        expect(PlatformUtils.supportsMultiThreading, isTrue);
      });
    });

    group('expectedGpuBackend', () {
      test('returns Metal for Apple platforms', () {
        final platform = PlatformUtils.current;
        if (platform == DartLLMPlatform.macos ||
            platform == DartLLMPlatform.ios) {
          expect(PlatformUtils.expectedGpuBackend, equals(GpuBackend.metal));
        }
      });

      test('returns CUDA for Windows and Linux', () {
        final platform = PlatformUtils.current;
        if (platform == DartLLMPlatform.windows ||
            platform == DartLLMPlatform.linux) {
          expect(PlatformUtils.expectedGpuBackend, equals(GpuBackend.cuda));
        }
      });
    });

    group('fallbackGpuBackends', () {
      test('returns Vulkan as fallback for Windows and Linux', () {
        final platform = PlatformUtils.current;
        if (platform == DartLLMPlatform.windows ||
            platform == DartLLMPlatform.linux) {
          expect(
            PlatformUtils.fallbackGpuBackends,
            contains(GpuBackend.vulkan),
          );
        }
      });

      test('returns empty list for Apple platforms', () {
        final platform = PlatformUtils.current;
        if (platform == DartLLMPlatform.macos ||
            platform == DartLLMPlatform.ios) {
          expect(PlatformUtils.fallbackGpuBackends, isEmpty);
        }
      });
    });

    group('platformName', () {
      test('returns human-readable name', () {
        final name = PlatformUtils.platformName;

        expect(name, isNotEmpty);
        expect(name, isNot(equals('unknown')));
      });

      test('matches expected names', () {
        final platform = PlatformUtils.current;
        final name = PlatformUtils.platformName;

        switch (platform) {
          case DartLLMPlatform.macos:
            expect(name, equals('macOS'));
          case DartLLMPlatform.windows:
            expect(name, equals('Windows'));
          case DartLLMPlatform.linux:
            expect(name, equals('Linux'));
          default:
            break;
        }
      });
    });

    group('osVersion', () {
      test('returns non-empty version string', () {
        final version = PlatformUtils.osVersion;

        expect(version, isNotEmpty);
      });
    });

    group('processorCount', () {
      test('returns positive number', () {
        final count = PlatformUtils.processorCount;

        expect(count, greaterThan(0));
      });

      test('matches Platform.numberOfProcessors', () {
        expect(PlatformUtils.processorCount, equals(Platform.numberOfProcessors));
      });
    });

    group('recommendedThreadCount', () {
      test('returns positive number', () {
        final count = PlatformUtils.recommendedThreadCount;

        expect(count, greaterThan(0));
      });

      test('is less than or equal to processor count', () {
        expect(
          PlatformUtils.recommendedThreadCount,
          lessThanOrEqualTo(PlatformUtils.processorCount),
        );
      });
    });

    group('minimumVersions', () {
      test('contains entries for all platforms', () {
        expect(
          PlatformUtils.minimumVersions,
          containsPair(DartLLMPlatform.android, isNotEmpty),
        );
        expect(
          PlatformUtils.minimumVersions,
          containsPair(DartLLMPlatform.ios, isNotEmpty),
        );
        expect(
          PlatformUtils.minimumVersions,
          containsPair(DartLLMPlatform.macos, isNotEmpty),
        );
        expect(
          PlatformUtils.minimumVersions,
          containsPair(DartLLMPlatform.windows, isNotEmpty),
        );
        expect(
          PlatformUtils.minimumVersions,
          containsPair(DartLLMPlatform.linux, isNotEmpty),
        );
        expect(
          PlatformUtils.minimumVersions,
          containsPair(DartLLMPlatform.web, isNotEmpty),
        );
      });
    });

    group('isSupported', () {
      test('returns true for known platforms', () {
        if (PlatformUtils.current != DartLLMPlatform.unknown) {
          expect(PlatformUtils.isSupported, isTrue);
        }
      });
    });
  });

  group('DartLLMPlatform enum', () {
    test('contains all expected values', () {
      expect(DartLLMPlatform.values, hasLength(7));
      expect(DartLLMPlatform.values, contains(DartLLMPlatform.android));
      expect(DartLLMPlatform.values, contains(DartLLMPlatform.ios));
      expect(DartLLMPlatform.values, contains(DartLLMPlatform.macos));
      expect(DartLLMPlatform.values, contains(DartLLMPlatform.windows));
      expect(DartLLMPlatform.values, contains(DartLLMPlatform.linux));
      expect(DartLLMPlatform.values, contains(DartLLMPlatform.web));
      expect(DartLLMPlatform.values, contains(DartLLMPlatform.unknown));
    });
  });

  group('GpuBackend enum', () {
    test('contains all expected values', () {
      expect(GpuBackend.values, hasLength(6));
      expect(GpuBackend.values, contains(GpuBackend.metal));
      expect(GpuBackend.values, contains(GpuBackend.cuda));
      expect(GpuBackend.values, contains(GpuBackend.vulkan));
      expect(GpuBackend.values, contains(GpuBackend.openCL));
      expect(GpuBackend.values, contains(GpuBackend.webGpu));
      expect(GpuBackend.values, contains(GpuBackend.none));
    });
  });
}

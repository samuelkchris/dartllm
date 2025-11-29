import 'dart:io' show Platform;

/// Supported runtime platforms for DartLLM.
enum DartLLMPlatform {
  /// Android devices (phones, tablets)
  android,

  /// iOS devices (iPhone, iPad)
  ios,

  /// macOS desktop
  macos,

  /// Windows desktop
  windows,

  /// Linux desktop
  linux,

  /// Web browser (Chrome, Firefox, Safari)
  web,

  /// Unknown or unsupported platform
  unknown,
}

/// GPU acceleration backends.
enum GpuBackend {
  /// Apple Metal (iOS, macOS)
  metal,

  /// NVIDIA CUDA (Windows, Linux)
  cuda,

  /// Vulkan (Android, Windows, Linux)
  vulkan,

  /// OpenCL (Android fallback)
  openCL,

  /// WebGPU (Web, experimental)
  webGpu,

  /// No GPU acceleration available
  none,
}

/// Platform detection and capability utilities.
///
/// Provides information about the current runtime environment,
/// available features, and hardware capabilities.
///
/// ```dart
/// if (PlatformUtils.current == DartLLMPlatform.ios) {
///   // iOS-specific handling
/// }
///
/// if (PlatformUtils.supportsGpuAcceleration) {
///   // Enable GPU features
/// }
/// ```
abstract final class PlatformUtils {
  /// The current runtime platform.
  static DartLLMPlatform get current {
    if (_isWeb) return DartLLMPlatform.web;

    if (Platform.isAndroid) return DartLLMPlatform.android;
    if (Platform.isIOS) return DartLLMPlatform.ios;
    if (Platform.isMacOS) return DartLLMPlatform.macos;
    if (Platform.isWindows) return DartLLMPlatform.windows;
    if (Platform.isLinux) return DartLLMPlatform.linux;

    return DartLLMPlatform.unknown;
  }

  /// Whether the current platform is a mobile device.
  static bool get isMobile {
    final platform = current;
    return platform == DartLLMPlatform.android ||
        platform == DartLLMPlatform.ios;
  }

  /// Whether the current platform is a desktop OS.
  static bool get isDesktop {
    final platform = current;
    return platform == DartLLMPlatform.macos ||
        platform == DartLLMPlatform.windows ||
        platform == DartLLMPlatform.linux;
  }

  /// Whether running in a web browser.
  static bool get isWeb => _isWeb;

  /// Whether the platform supports native FFI bindings.
  ///
  /// Web uses WASM instead of FFI.
  static bool get supportsFFI => !isWeb;

  /// Whether the platform potentially supports GPU acceleration.
  ///
  /// This indicates the platform can have GPU support, not that
  /// a GPU is actually available. Use [detectGpuBackend] for
  /// runtime detection.
  static bool get supportsGpuAcceleration {
    switch (current) {
      case DartLLMPlatform.android:
      case DartLLMPlatform.ios:
      case DartLLMPlatform.macos:
      case DartLLMPlatform.windows:
      case DartLLMPlatform.linux:
        return true;
      case DartLLMPlatform.web:
        return true; // WebGPU support (experimental)
      case DartLLMPlatform.unknown:
        return false;
    }
  }

  /// The primary GPU backend for the current platform.
  ///
  /// Returns the expected GPU backend based on platform.
  /// Actual availability depends on hardware and drivers.
  static GpuBackend get expectedGpuBackend {
    switch (current) {
      case DartLLMPlatform.ios:
      case DartLLMPlatform.macos:
        return GpuBackend.metal;
      case DartLLMPlatform.android:
        return GpuBackend.vulkan;
      case DartLLMPlatform.windows:
      case DartLLMPlatform.linux:
        return GpuBackend.cuda; // CUDA preferred, Vulkan fallback
      case DartLLMPlatform.web:
        return GpuBackend.webGpu;
      case DartLLMPlatform.unknown:
        return GpuBackend.none;
    }
  }

  /// Fallback GPU backends for the current platform.
  ///
  /// Returns alternative backends to try if the primary fails.
  static List<GpuBackend> get fallbackGpuBackends {
    switch (current) {
      case DartLLMPlatform.android:
        return [GpuBackend.openCL];
      case DartLLMPlatform.windows:
      case DartLLMPlatform.linux:
        return [GpuBackend.vulkan];
      case DartLLMPlatform.ios:
      case DartLLMPlatform.macos:
      case DartLLMPlatform.web:
      case DartLLMPlatform.unknown:
        return [];
    }
  }

  /// Whether the platform supports memory mapping for model files.
  static bool get supportsMemoryMapping => !isWeb;

  /// Whether the platform supports multi-threaded inference.
  static bool get supportsMultiThreading => !isWeb;

  /// The platform's display name for logging and error messages.
  static String get platformName {
    switch (current) {
      case DartLLMPlatform.android:
        return 'Android';
      case DartLLMPlatform.ios:
        return 'iOS';
      case DartLLMPlatform.macos:
        return 'macOS';
      case DartLLMPlatform.windows:
        return 'Windows';
      case DartLLMPlatform.linux:
        return 'Linux';
      case DartLLMPlatform.web:
        return 'Web';
      case DartLLMPlatform.unknown:
        return 'Unknown';
    }
  }

  /// The operating system version string.
  ///
  /// Returns an empty string on web.
  static String get osVersion {
    if (isWeb) return '';
    return Platform.operatingSystemVersion;
  }

  /// Number of available processor cores.
  ///
  /// Used for default thread count calculation.
  /// Returns 1 on web (single-threaded WASM).
  static int get processorCount {
    if (isWeb) return 1;
    return Platform.numberOfProcessors;
  }

  /// Recommended thread count for inference.
  ///
  /// Returns an optimal thread count based on processor cores,
  /// leaving some headroom for UI and system tasks.
  static int get recommendedThreadCount {
    final cores = processorCount;
    if (cores <= 2) return 1;
    if (cores <= 4) return cores - 1;
    return cores - 2;
  }

  /// Minimum supported platform versions.
  static const Map<DartLLMPlatform, String> minimumVersions = {
    DartLLMPlatform.android: 'API 24 (Android 7.0)',
    DartLLMPlatform.ios: 'iOS 14.0',
    DartLLMPlatform.macos: 'macOS 11.0',
    DartLLMPlatform.windows: 'Windows 10 (1809)',
    DartLLMPlatform.linux: 'glibc 2.31+',
    DartLLMPlatform.web: 'Chrome 119+, Firefox 120+',
  };

  /// Checks if the current platform is supported.
  static bool get isSupported => current != DartLLMPlatform.unknown;
}

/// Detects if running in a web environment.
///
/// Uses the `dart.library.html` conditional import pattern.
const bool _isWeb = bool.fromEnvironment('dart.library.html');

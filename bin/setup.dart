#!/usr/bin/env dart
/// DartLLM Setup Script
///
/// This script builds the native library for your platform and places it
/// in the correct location for DartLLM to find it.
///
/// Usage: dart run dartllm:setup
library;

import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  print('╔══════════════════════════════════════════════════════════════════╗');
  print('║                     DartLLM Native Library Setup                 ║');
  print('╚══════════════════════════════════════════════════════════════════╝');
  print('');

  final packageRoot = _findPackageRoot();
  if (packageRoot == null) {
    print('❌ Error: Could not find DartLLM package root');
    exit(1);
  }

  print('📁 Package root: $packageRoot');
  print('🖥️  Platform: ${Platform.operatingSystem}');
  print('');

  // Check if llama.cpp submodule is initialized
  final llamaCppDir = Directory(p.join(packageRoot, 'native', 'llama.cpp'));
  if (!llamaCppDir.existsSync() ||
      !File(p.join(llamaCppDir.path, 'CMakeLists.txt')).existsSync()) {
    print('📥 Initializing llama.cpp submodule...');
    final result = await _runCommand('git', ['submodule', 'update', '--init', '--recursive'],
        workingDirectory: packageRoot);
    if (result != 0) {
      print('❌ Failed to initialize submodule. Please run manually:');
      print('   git submodule update --init --recursive');
      exit(1);
    }
  }

  // Determine platform and build
  if (Platform.isMacOS) {
    await _buildMacOS(packageRoot);
  } else if (Platform.isLinux) {
    await _buildLinux(packageRoot);
  } else if (Platform.isWindows) {
    await _buildWindows(packageRoot);
  } else {
    print('❌ Unsupported platform: ${Platform.operatingSystem}');
    print('   Supported platforms: macOS, Linux, Windows');
    exit(1);
  }

  print('');
  print('╔══════════════════════════════════════════════════════════════════╗');
  print('║                        Setup Complete! ✅                        ║');
  print('╚══════════════════════════════════════════════════════════════════╝');
  print('');
  print('You can now use DartLLM in your Dart code:');
  print('');
  print('  import \'package:dartllm/dartllm.dart\';');
  print('');
  print('  final model = await DartLLM.loadModel(\'path/to/model.gguf\');');
  print('  final response = await model.complete(\'Hello, \');');
  print('  print(response.text);');
  print('');
}

Future<void> _buildMacOS(String packageRoot) async {
  print('🔨 Building for macOS with Metal support...');
  print('');

  final buildDir = p.join(packageRoot, 'native', 'build', 'macos');
  final nativeDir = p.join(packageRoot, 'native');

  // Create build directory
  await Directory(buildDir).create(recursive: true);

  // Run CMake configure
  print('⚙️  Configuring CMake...');
  var result = await _runCommand(
    'cmake',
    [
      '-B', buildDir,
      '-S', nativeDir,
      '-DCMAKE_BUILD_TYPE=Release',
      '-DGGML_METAL=ON',
      '-DGGML_METAL_EMBED_LIBRARY=ON',
      '-DLLAMA_BUILD_TESTS=OFF',
      '-DLLAMA_BUILD_EXAMPLES=OFF',
      '-DLLAMA_BUILD_SERVER=OFF',
      '-DBUILD_SHARED_LIBS=ON',
      '-DCMAKE_OSX_ARCHITECTURES=arm64;x86_64',
    ],
    workingDirectory: packageRoot,
  );

  if (result != 0) {
    print('❌ CMake configure failed');
    exit(1);
  }

  // Run CMake build
  print('🔧 Building native library...');
  result = await _runCommand(
    'cmake',
    ['--build', buildDir, '--config', 'Release', '-j', '${Platform.numberOfProcessors}'],
    workingDirectory: packageRoot,
  );

  if (result != 0) {
    print('❌ Build failed');
    exit(1);
  }

  // Copy framework to blobs directory
  final blobsDir = p.join(packageRoot, 'blobs', 'macos');
  await Directory(blobsDir).create(recursive: true);

  final frameworkSrc = Directory(p.join(buildDir, 'llamacpp.framework'));
  if (frameworkSrc.existsSync()) {
    print('📦 Copying framework to blobs directory...');
    await _copyDirectory(frameworkSrc, Directory(p.join(blobsDir, 'llamacpp.framework')));

    // Also copy to package root for immediate use
    await _copyDirectory(frameworkSrc, Directory(p.join(packageRoot, 'llamacpp.framework')));
  }

  print('✅ macOS build complete!');
}

Future<void> _buildLinux(String packageRoot) async {
  print('🔨 Building for Linux...');
  print('');

  final buildDir = p.join(packageRoot, 'native', 'build', 'linux');
  final nativeDir = p.join(packageRoot, 'native');

  await Directory(buildDir).create(recursive: true);

  // Check for CUDA
  final hasCuda = await _commandExists('nvcc');
  final cmakeArgs = <String>[
    '-B', buildDir,
    '-S', nativeDir,
    '-DCMAKE_BUILD_TYPE=Release',
    '-DLLAMA_BUILD_TESTS=OFF',
    '-DLLAMA_BUILD_EXAMPLES=OFF',
    '-DLLAMA_BUILD_SERVER=OFF',
    '-DBUILD_SHARED_LIBS=ON',
  ];

  if (hasCuda) {
    print('🎮 CUDA detected, enabling GPU acceleration...');
    cmakeArgs.add('-DGGML_CUDA=ON');
  }

  print('⚙️  Configuring CMake...');
  var result = await _runCommand('cmake', cmakeArgs, workingDirectory: packageRoot);

  if (result != 0) {
    print('❌ CMake configure failed');
    exit(1);
  }

  print('🔧 Building native library...');
  result = await _runCommand(
    'cmake',
    ['--build', buildDir, '--config', 'Release', '-j', '${Platform.numberOfProcessors}'],
    workingDirectory: packageRoot,
  );

  if (result != 0) {
    print('❌ Build failed');
    exit(1);
  }

  // Copy library to blobs
  final blobsDir = p.join(packageRoot, 'blobs', 'linux');
  await Directory(blobsDir).create(recursive: true);

  final libSrc = File(p.join(buildDir, 'libdartllm.so'));
  if (libSrc.existsSync()) {
    print('📦 Copying library to blobs directory...');
    await libSrc.copy(p.join(blobsDir, 'libdartllm.so'));
  }

  print('✅ Linux build complete!');
}

Future<void> _buildWindows(String packageRoot) async {
  print('🔨 Building for Windows...');
  print('');

  final buildDir = p.join(packageRoot, 'native', 'build', 'windows');
  final nativeDir = p.join(packageRoot, 'native');

  await Directory(buildDir).create(recursive: true);

  print('⚙️  Configuring CMake...');
  var result = await _runCommand(
    'cmake',
    [
      '-B', buildDir,
      '-S', nativeDir,
      '-DCMAKE_BUILD_TYPE=Release',
      '-DLLAMA_BUILD_TESTS=OFF',
      '-DLLAMA_BUILD_EXAMPLES=OFF',
      '-DLLAMA_BUILD_SERVER=OFF',
      '-DBUILD_SHARED_LIBS=ON',
    ],
    workingDirectory: packageRoot,
  );

  if (result != 0) {
    print('❌ CMake configure failed');
    exit(1);
  }

  print('🔧 Building native library...');
  result = await _runCommand(
    'cmake',
    ['--build', buildDir, '--config', 'Release'],
    workingDirectory: packageRoot,
  );

  if (result != 0) {
    print('❌ Build failed');
    exit(1);
  }

  // Copy DLL to blobs
  final blobsDir = p.join(packageRoot, 'blobs', 'windows');
  await Directory(blobsDir).create(recursive: true);

  for (final subdir in ['Release', 'Debug', '']) {
    final dllPath = p.join(buildDir, subdir, 'dartllm.dll');
    if (File(dllPath).existsSync()) {
      print('📦 Copying DLL to blobs directory...');
      await File(dllPath).copy(p.join(blobsDir, 'dartllm.dll'));
      break;
    }
  }

  print('✅ Windows build complete!');
}

String? _findPackageRoot() {
  // First try from current directory
  var dir = Directory.current;
  for (var i = 0; i < 10; i++) {
    final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
    if (pubspec.existsSync()) {
      final content = pubspec.readAsStringSync();
      if (content.contains('name: dartllm')) {
        return dir.path;
      }
    }
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }

  // Try from script location
  if (Platform.script.scheme == 'file') {
    final scriptPath = Platform.script.toFilePath();
    dir = Directory(p.dirname(scriptPath));
    for (var i = 0; i < 10; i++) {
      final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
      if (pubspec.existsSync()) {
        final content = pubspec.readAsStringSync();
        if (content.contains('name: dartllm')) {
          return dir.path;
        }
      }
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
  }

  return null;
}

Future<int> _runCommand(String command, List<String> args,
    {String? workingDirectory}) async {
  final process = await Process.start(
    command,
    args,
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}

Future<bool> _commandExists(String command) async {
  try {
    final result = await Process.run('which', [command]);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

Future<void> _copyDirectory(Directory source, Directory destination) async {
  await destination.create(recursive: true);
  await for (final entity in source.list(recursive: false)) {
    final newPath = p.join(destination.path, p.basename(entity.path));
    if (entity is File) {
      await entity.copy(newPath);
    } else if (entity is Directory) {
      await _copyDirectory(entity, Directory(newPath));
    } else if (entity is Link) {
      final target = await entity.target();
      await Link(newPath).create(target);
    }
  }
}

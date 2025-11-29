import 'dart:convert';
import 'dart:io';

import 'package:dartllm/src/core/exceptions/network_exception.dart';
import 'package:dartllm/src/utils/logger.dart';

/// Information about a file in a HuggingFace repository.
class HuggingFaceFile {
  /// The filename.
  final String filename;

  /// Size in bytes.
  final int sizeBytes;

  /// The file's blob ID (SHA).
  final String? blobId;

  /// Whether this is an LFS file.
  final bool isLfs;

  /// Creates HuggingFace file info.
  const HuggingFaceFile({
    required this.filename,
    required this.sizeBytes,
    this.blobId,
    this.isLfs = false,
  });

  /// Size in megabytes.
  double get sizeMB => sizeBytes / (1024 * 1024);

  /// Size in gigabytes.
  double get sizeGB => sizeBytes / (1024 * 1024 * 1024);

  @override
  String toString() => 'HuggingFaceFile($filename, ${sizeMB.toStringAsFixed(1)} MB)';
}

/// Information about a HuggingFace repository.
class HuggingFaceRepo {
  /// The repository ID (e.g., 'TheBloke/Llama-2-7B-GGUF').
  final String repoId;

  /// The model name.
  final String? modelName;

  /// The repository author/organization.
  final String author;

  /// List of files in the repository.
  final List<HuggingFaceFile> files;

  /// The default branch (usually 'main').
  final String branch;

  /// Creates HuggingFace repo info.
  const HuggingFaceRepo({
    required this.repoId,
    this.modelName,
    required this.author,
    required this.files,
    this.branch = 'main',
  });

  /// Gets GGUF files from the repository.
  List<HuggingFaceFile> get ggufFiles =>
      files.where((f) => f.filename.toLowerCase().endsWith('.gguf')).toList();

  @override
  String toString() => 'HuggingFaceRepo($repoId, ${files.length} files)';
}

/// Client for interacting with the HuggingFace Hub API.
///
/// Provides functionality for:
/// - Listing repository files
/// - Resolving download URLs
/// - Fetching model metadata
///
/// Example usage:
/// ```dart
/// final client = HuggingFaceClient();
///
/// // Get repository info
/// final repo = await client.getRepoInfo('TheBloke/Llama-2-7B-GGUF');
///
/// // List GGUF files
/// for (final file in repo.ggufFiles) {
///   print('${file.filename}: ${file.sizeMB.toStringAsFixed(1)} MB');
/// }
///
/// // Get download URL
/// final url = client.getDownloadUrl(
///   'TheBloke/Llama-2-7B-GGUF',
///   'llama-2-7b.Q4_K_M.gguf',
/// );
/// ```
class HuggingFaceClient {
  static const String _loggerName = 'dartllm.core.huggingface';
  final DartLLMLogger _logger = DartLLMLogger(_loggerName);

  /// Base URL for the HuggingFace API.
  static const String _apiBaseUrl = 'https://huggingface.co/api';

  /// Base URL for file downloads.
  static const String _downloadBaseUrl = 'https://huggingface.co';

  /// HTTP client.
  final HttpClient _client;

  /// Optional API token for authenticated requests.
  final String? _apiToken;

  /// Creates a HuggingFaceClient.
  ///
  /// [apiToken] is optional but allows access to private repos and
  /// increases rate limits.
  HuggingFaceClient({String? apiToken})
      : _apiToken = apiToken,
        _client = HttpClient() {
    _client.connectionTimeout = const Duration(seconds: 30);
    _client.idleTimeout = const Duration(seconds: 60);
  }

  /// Gets information about a repository.
  ///
  /// [repoId] is the repository identifier (e.g., 'TheBloke/Llama-2-7B-GGUF').
  /// [branch] is the branch to query (default: 'main').
  ///
  /// Returns [HuggingFaceRepo] with repository info and file list.
  ///
  /// Throws [DownloadException] if the request fails.
  Future<HuggingFaceRepo> getRepoInfo(
    String repoId, {
    String branch = 'main',
  }) async {
    _logger.info('Fetching repo info: $repoId');

    final files = await listFiles(repoId, branch: branch);

    final parts = repoId.split('/');
    final author = parts.isNotEmpty ? parts[0] : '';
    final modelName = parts.length > 1 ? parts[1] : null;

    return HuggingFaceRepo(
      repoId: repoId,
      modelName: modelName,
      author: author,
      files: files,
      branch: branch,
    );
  }

  /// Lists files in a repository.
  ///
  /// [repoId] is the repository identifier.
  /// [branch] is the branch to list (default: 'main').
  /// [path] is an optional subdirectory path.
  ///
  /// Returns a list of [HuggingFaceFile] objects.
  Future<List<HuggingFaceFile>> listFiles(
    String repoId, {
    String branch = 'main',
    String? path,
  }) async {
    _logger.debug('Listing files: $repoId/$branch${path != null ? '/$path' : ''}');

    var url = '$_apiBaseUrl/models/$repoId/tree/$branch';
    if (path != null && path.isNotEmpty) {
      url += '/$path';
    }

    final data = await _get(url);

    if (data is! List) {
      throw DownloadException(url, message: 'Invalid response from HuggingFace API');
    }

    final files = <HuggingFaceFile>[];

    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final type = item['type'] as String?;
        if (type == 'file') {
          files.add(HuggingFaceFile(
            filename: item['path'] as String? ?? '',
            sizeBytes: item['size'] as int? ?? 0,
            blobId: item['oid'] as String?,
            isLfs: item['lfs'] != null,
          ));
        }
      }
    }

    _logger.debug('Found ${files.length} files');
    return files;
  }

  /// Gets the download URL for a file.
  ///
  /// [repoId] is the repository identifier.
  /// [filename] is the file to download.
  /// [branch] is the branch (default: 'main').
  ///
  /// Returns the direct download URL.
  String getDownloadUrl(
    String repoId,
    String filename, {
    String branch = 'main',
  }) {
    return '$_downloadBaseUrl/$repoId/resolve/$branch/$filename';
  }

  /// Checks if a file exists in a repository.
  ///
  /// [repoId] is the repository identifier.
  /// [filename] is the file to check.
  /// [branch] is the branch (default: 'main').
  Future<bool> fileExists(
    String repoId,
    String filename, {
    String branch = 'main',
  }) async {
    try {
      final url = getDownloadUrl(repoId, filename, branch: branch);
      final uri = Uri.parse(url);
      final request = await _client.headUrl(uri);
      _addAuthHeader(request);

      final response = await request.close();
      await response.drain<void>();

      return response.statusCode == 200;
    } catch (e) {
      _logger.warning('Failed to check file existence: $filename', e);
      return false;
    }
  }

  /// Gets the size of a file without downloading it.
  ///
  /// Returns the size in bytes, or null if unknown.
  Future<int?> getFileSize(
    String repoId,
    String filename, {
    String branch = 'main',
  }) async {
    try {
      final url = getDownloadUrl(repoId, filename, branch: branch);
      final uri = Uri.parse(url);
      final request = await _client.headUrl(uri);
      _addAuthHeader(request);

      final response = await request.close();
      await response.drain<void>();

      if (response.statusCode == 200 && response.contentLength > 0) {
        return response.contentLength;
      }

      return null;
    } catch (e) {
      _logger.warning('Failed to get file size: $filename', e);
      return null;
    }
  }

  /// Searches for repositories matching a query.
  ///
  /// [query] is the search term.
  /// [filter] can be 'gguf' to filter GGUF models.
  /// [limit] is the maximum results to return.
  ///
  /// Returns a list of repository IDs.
  Future<List<String>> searchRepos(
    String query, {
    String? filter,
    int limit = 10,
  }) async {
    _logger.debug('Searching repos: $query');

    var url = '$_apiBaseUrl/models?search=$query&limit=$limit';
    if (filter != null) {
      url += '&filter=$filter';
    }

    final data = await _get(url);

    if (data is! List) {
      return [];
    }

    final repos = <String>[];
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        final modelId = item['modelId'] as String?;
        if (modelId != null) {
          repos.add(modelId);
        }
      }
    }

    return repos;
  }

  /// Closes the HTTP client.
  void close() {
    _client.close(force: true);
  }

  /// Makes a GET request and returns parsed JSON.
  Future<dynamic> _get(String url) async {
    try {
      final uri = Uri.parse(url);
      final request = await _client.getUrl(uri);
      _addAuthHeader(request);

      final response = await request.close();

      if (response.statusCode != 200) {
        throw DownloadException(
          url,
          message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      final body = await response.transform(utf8.decoder).join();
      return json.decode(body);
    } on SocketException catch (e) {
      throw ConnectionException(
        'Connection failed: ${e.message}',
        host: e.address?.host,
        cause: e,
      );
    } on FormatException catch (e) {
      throw DownloadException(url, message: 'Invalid JSON response: ${e.message}');
    }
  }

  /// Adds authorization header if token is configured.
  void _addAuthHeader(HttpClientRequest request) {
    if (_apiToken != null) {
      request.headers.set('Authorization', 'Bearer $_apiToken');
    }
  }
}

/// Mirrors [HTTPUrl.swift] — HttpURL struct
///
/// Holds a base URL string and optional query parameters,
/// and provides a computed [queryParamUri] that appends them.
class HttpUrl {
  final String _baseUrl;
  final Map<String, String>? components;

  /// Creates an [HttpUrl] with a plain URL string.
  HttpUrl(String url) : _baseUrl = url, components = null;

  /// Creates an [HttpUrl] with a URL string and optional query parameters.
  HttpUrl.withComponents(String url, {this.components}) : _baseUrl = url;

  /// Returns the raw [Uri], without any query parameters appended.
  Uri? get uri => Uri.tryParse(_baseUrl);

  /// Returns a [Uri] with [components] merged into the query string.
  ///
  /// Mirrors `queryParamUrl` in Swift: existing query params are preserved
  /// and the [components] map entries are appended.
  Uri? get queryParamUri {
    final base = Uri.tryParse(_baseUrl);
    if (base == null) return null;

    // Merge existing query params with the new ones
    final mergedParams = Map<String, String>.from(base.queryParameters);
    if (components != null) {
      mergedParams.addAll(components!);
    }

    return base.replace(queryParameters: mergedParams.isEmpty ? null : mergedParams);
  }
}

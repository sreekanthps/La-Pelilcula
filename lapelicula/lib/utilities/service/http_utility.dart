import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

import 'http_methods.dart';
import 'http_network_error.dart';
import 'http_request.dart';

/// Mirrors [HttpUtility.swift] — Singleton HTTP networking utility.
///
/// Supports:
/// - Generic GET / POST with JSON decoding via [request]
/// - Direct [getData] / [postData] methods
/// - [readJsonResponse] / [readJsonArrayResponse] for local asset JSON files
///
/// ### Usage
/// ```dart
/// final (error, movie) = await HttpUtility.shared.request<Movie>(
///   request: HttpRequest(url: uri, method: HttpMethods.GET),
///   fromJson: Movie.fromJson,
/// );
/// if (error != null) print(error);
/// else print(movie);
/// ```
class HttpUtility {
  // ---------------------------------------------------------------------------
  // Shared Instance  (mirrors `static let shared = HttpUtility()`)
  // ---------------------------------------------------------------------------
  static final HttpUtility shared = HttpUtility._internal();
  HttpUtility._internal();

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  /// Optional Bearer / custom auth token appended to every request header.
  /// Mirrors `var authToken: String?`
  String? authToken;

  /// Supply a custom JSON reviver if you need non-default decoding behaviour.
  /// Mirrors `var customJsonDecoder: JSONDecoder?`
  Object? Function(Object? key, Object? value)? customJsonReviver;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Dispatches [request] and decodes the response into [T].
  ///
  /// Returns a Dart record `(HttpNetworkError?, T?)`:
  ///   - `(null, value)`  on success   ← mirrors `.success`
  ///   - `(error, null)`  on failure   ← mirrors `.failure`
  Future<(HttpNetworkError?, T?)> request<T>({
    required HttpRequest request,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    switch (request.method) {
      case HttpMethods.GET:
        return getData(requestUrl: request.url, fromJson: fromJson);
      case HttpMethods.POST:
        return postData(request: request, fromJson: fromJson);
    }
  }

  // ---------------------------------------------------------------------------
  // GET  (mirrors `getData`)
  // ---------------------------------------------------------------------------

  Future<(HttpNetworkError?, T?)> getData<T>({
    required Uri requestUrl,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    return _performOperation(
      request: HttpRequest(url: requestUrl, method: HttpMethods.GET),
      fromJson: fromJson,
    );
  }

  // ---------------------------------------------------------------------------
  // POST  (mirrors `postData`)
  // ---------------------------------------------------------------------------

  Future<(HttpNetworkError?, T?)> postData<T>({
    required HttpRequest request,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    return _performOperation(request: request, fromJson: fromJson);
  }

  // ---------------------------------------------------------------------------
  // Local JSON asset helpers  (mirrors readJsonResponse / readJsonArrayResponse)
  // ---------------------------------------------------------------------------

  /// Reads a bundled JSON asset and decodes it into [T].
  ///
  /// [name] — asset path, e.g. `'assets/data/movies.json'`
  Future<T?> readJsonResponse<T>({
    required String name,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final raw = await rootBundle.loadString(name);
      final decoded = _decodeJson(raw);
      if (decoded is Map<String, dynamic>) return fromJson(decoded);
      _debugLog('readJsonResponse: unexpected top-level type for $name');
    } catch (e) {
      _debugLog('readJsonResponse: $e');
    }
    return null;
  }

  /// Reads a bundled JSON asset containing a top-level array, decoding each
  /// element into [T].
  Future<List<T>?> readJsonArrayResponse<T>({
    required String name,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final raw = await rootBundle.loadString(name);
      final decoded = _decodeJson(raw);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().map(fromJson).toList();
      }
      _debugLog('readJsonArrayResponse: top-level is not a List for $name');
    } catch (e) {
      _debugLog('readJsonArrayResponse: $e');
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Builds request headers, injecting [authToken] and Content-Type for POST.
  /// Mirrors `createUrlRequest` in Swift.
  Map<String, String> _buildHeaders({bool includeContentType = false}) {
    final headers = <String, String>{};
    if (authToken != null) headers['Authorization'] = authToken!;
    if (includeContentType) headers['Content-Type'] = 'application/json';
    return headers;
  }

  /// Core network dispatcher — mirrors `performOperation` in Swift.
  Future<(HttpNetworkError?, T?)> _performOperation<T>({
    required HttpRequest request,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final isPost = request.method == HttpMethods.POST;
    final headers = _buildHeaders(includeContentType: isPost);

    try {
      final http.Response response;

      if (isPost) {
        response = await http.post(
          request.url,
          headers: headers,
          body: request.requestBody,
        );
      } else {
        response = await http.get(request.url, headers: headers);
      }

      final statusCode = response.statusCode;
      final bodyBytes = response.bodyBytes;

      // Mirror Swift: success when data is non-empty and decoding works
      if (bodyBytes.isNotEmpty) {
        final decoded = _decodeJson(response.body);
        if (decoded is Map<String, dynamic>) {
          try {
            return (null, fromJson(decoded));
          } catch (e) {
            _debugLog('_performOperation decoding error => $e');
            return (
              HttpNetworkError(
                responseBytes: bodyBytes,
                requestUrl: request.url,
                bodyBytes: request.requestBody,
                message: 'JSON model decoding failed: $e',
                httpStatusCode: statusCode,
              ),
              null,
            );
          }
        }
      }

      return (
        HttpNetworkError(
          responseBytes: response.bodyBytes,
          requestUrl: request.url,
          bodyBytes: request.requestBody,
          message: 'Empty or non-JSON response',
          httpStatusCode: statusCode,
        ),
        null,
      );
    } catch (e) {
      return (
        HttpNetworkError(
          requestUrl: request.url,
          bodyBytes: request.requestBody,
          message: e.toString(),
        ),
        null,
      );
    }
  }

  /// Decodes a JSON string; supports optional [customJsonReviver].
  Object? _decodeJson(String raw) =>
      json.decode(raw, reviver: customJsonReviver);

  void _debugLog(String message) {
    assert(() {
      // ignore: avoid_print
      print('[HttpUtility] $message');
      return true;
    }());
  }
}

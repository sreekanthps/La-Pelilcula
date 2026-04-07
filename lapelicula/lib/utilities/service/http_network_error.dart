/// Mirrors [HttpNetworkError.swift] — HttpNetworkError struct
///
/// Implements [Exception] (Dart's equivalent of Swift's Error protocol).
/// Carries all contextual data about a failed HTTP operation.
class HttpNetworkError implements Exception {
  /// Human-readable reason / message.
  final String? reason;

  /// HTTP status code returned by the server (may be null for network errors).
  final int? httpStatusCode;

  /// The URL that was requested.
  final Uri? requestUrl;

  /// The request body sent (decoded to a string for readability).
  final String? requestBody;

  /// The raw server response body (decoded to a string).
  final String? serverResponse;

  /// Creates an [HttpNetworkError].
  ///
  /// [responseBytes]   — raw response body bytes (optional)
  /// [requestUrl]      — the URL that was requested
  /// [bodyBytes]       — raw request body bytes (optional)
  /// [message]         — human-readable error description
  /// [statusCode]      — HTTP status code (optional for network/socket errors)
  HttpNetworkError({
    List<int>? responseBytes,
    this.requestUrl,
    List<int>? bodyBytes,
    required String message,
    this.httpStatusCode,
  })  : reason = message,
        serverResponse = responseBytes != null
            ? String.fromCharCodes(responseBytes)
            : null,
        requestBody = bodyBytes != null
            ? String.fromCharCodes(bodyBytes)
            : null;

  @override
  String toString() =>
      'HttpNetworkError(status: $httpStatusCode, reason: $reason, url: $requestUrl)';
}

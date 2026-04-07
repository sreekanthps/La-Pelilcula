import 'http_methods.dart';

/// Mirrors [HttpRequest.swift] — Request protocol + HttpRequest struct
///
/// [Request] is the abstract contract (equivalent to the Swift protocol).
/// [HttpRequest] is the concrete implementation.
abstract class Request {
  Uri get url;
  HttpMethods get method;
}

/// Concrete HTTP request descriptor.
///
/// Holds everything needed by [HttpUtility] to dispatch a network call.
class HttpRequest implements Request {
  @override
  final Uri url;

  @override
  final HttpMethods method;

  /// Optional body bytes for POST requests.
  final List<int>? requestBody;

  /// Creates an [HttpRequest].
  ///
  /// [url]         — the fully resolved [Uri]
  /// [method]      — GET or POST
  /// [requestBody] — raw bytes to send as the request body (POST only)
  const HttpRequest({
    required this.url,
    required this.method,
    this.requestBody,
  });
}

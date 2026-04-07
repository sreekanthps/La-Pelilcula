/// Mirrors [HttpMethods.swift] — HTTPMethods enum
///
/// Defines the supported HTTP verb types for outgoing requests.
library;
enum HttpMethods {
  // ignore: constant_identifier_names
  GET,
  // ignore: constant_identifier_names
  POST,
}

extension HttpMethodsExtension on HttpMethods {
  /// Returns the raw HTTP verb string, e.g. "GET", "POST".
  String get value => name;
}

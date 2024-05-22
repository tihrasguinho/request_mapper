import 'dart:io' as io;

class Response {
  final void Function(int statusCode, {Map<String, String>? headers, Object? body}) send;
  const Response(this.send);

  /// Sends a plain text response.
  void call(int statusCode, {Map<String, String>? headers, Object? body}) {
    return send(statusCode, headers: headers, body: body);
  }

  /// Sends a JSON response.
  void json(int statusCode, {Map<String, String>? headers, Map<String, dynamic>? body}) {
    return send(
      statusCode,
      headers: {
        io.HttpHeaders.contentTypeHeader: 'application/json',
        ...?headers,
      },
      body: body,
    );
  }

  /// Sends a binary response.
  void bytes(int statusCode, {Map<String, String>? headers, List<int>? body}) {
    return send(
      statusCode,
      headers: {
        io.HttpHeaders.contentTypeHeader: 'application/octet-stream',
        ...?headers,
      },
      body: body,
    );
  }

  /// Sends a stream response.
  void stream(int statusCode, {Map<String, String>? headers, Stream<List<int>>? body}) {
    return send(
      statusCode,
      headers: {
        io.HttpHeaders.contentTypeHeader: 'application/octet-stream',
        io.HttpHeaders.transferEncodingHeader: 'chunked',
        ...?headers,
      },
      body: body,
    );
  }
}

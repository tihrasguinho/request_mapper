import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'multipart.dart';

class Request extends Stream<Uint8List> {
  final Uri uri;
  final Map<String, String> headers;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final Map<String, dynamic> context;
  final Stream<Uint8List> body;

  const Request({
    required this.uri,
    this.headers = const {},
    this.pathParameters = const {},
    this.queryParameters = const {},
    this.context = const {},
    this.body = const Stream.empty(),
  });

  factory Request.fromHttpRequest(io.HttpRequest request) {
    return Request(
      uri: request.uri,
      headers: {
        io.HttpHeaders.contentTypeHeader: request.headers.value(io.HttpHeaders.contentTypeHeader) ?? 'text/plain',
        io.HttpHeaders.contentLengthHeader: request.headers.value(io.HttpHeaders.contentLengthHeader) ?? '0',
        io.HttpHeaders.cookieHeader: request.headers.value(io.HttpHeaders.cookieHeader) ?? '',
        io.HttpHeaders.hostHeader: request.headers.value(io.HttpHeaders.hostHeader) ?? '',
        io.HttpHeaders.userAgentHeader: request.headers.value(io.HttpHeaders.userAgentHeader) ?? '',
        io.HttpHeaders.authorizationHeader: request.headers.value(io.HttpHeaders.authorizationHeader) ?? '',
        io.HttpHeaders.connectionHeader: request.headers.value(io.HttpHeaders.connectionHeader) ?? '',
        io.HttpHeaders.transferEncodingHeader: request.headers.value(io.HttpHeaders.transferEncodingHeader) ?? '',
        io.HttpHeaders.proxyAuthorizationHeader: request.headers.value(io.HttpHeaders.proxyAuthorizationHeader) ?? '',
        io.HttpHeaders.dateHeader: request.headers.value(io.HttpHeaders.dateHeader) ?? DateTime.now().toIso8601String(),
      }..removeWhere((key, value) => value.isEmpty),
      queryParameters: request.uri.queryParameters,
      pathParameters: {},
      body: request,
    );
  }

  /// Checks if the request is JSON.
  bool get json => headers[io.HttpHeaders.contentTypeHeader]?.contains('application/json') ?? false;

  /// Checks if the request is multipart.
  bool get multipart => headers[io.HttpHeaders.contentTypeHeader]?.contains('multipart/form-data') ?? false;

  /// Checks if the request is text.
  bool get text => headers[io.HttpHeaders.contentTypeHeader]?.contains('text/plain') ?? false;

  /// Gets the request content length.
  int get contentLength => int.tryParse(headers[io.HttpHeaders.contentLengthHeader] ?? '0') ?? 0;

  /// Reads the request body as a string.
  Future<String> readString([Encoding encoding = utf8]) async {
    if (json && contentLength > 0) {
      final chunks = <List<int>>[];
      await for (final chunk in this) {
        chunks.add(chunk);
      }
      return encoding.decode(chunks.expand((element) => element).toList());
    } else {
      return '{}';
    }
  }

  /// Reads the request body as a [Map].
  Future<Map<String, dynamic>> readMap() async {
    if (json && contentLength > 0) {
      return jsonDecode(await readString());
    } else {
      return {};
    }
  }

  /// Copies the request merging the given parameters.
  Request copy({
    Uri? uri,
    Map<String, String>? headers,
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? context,
    Stream<Uint8List>? body,
  }) {
    return Request(
      uri: uri ?? this.uri,
      headers: {...this.headers, ...?headers},
      pathParameters: {...this.pathParameters, ...?pathParameters},
      queryParameters: {...this.queryParameters, ...?queryParameters},
      context: {...this.context, ...?context},
      body: body ?? this.body,
    );
  }

  /// Stream that provides access to the request body parts.
  Stream<Multipart> get parts {
    if (!headers.keys.any((key) => key.toLowerCase() == 'content-type')) {
      throw UnsupportedError('Request does not have a Content-Type header');
    }

    final contentType = MediaType.parse(headers.entries.firstWhere((entry) => entry.key.toLowerCase() == 'content-type').value);

    if (contentType.type != 'multipart') {
      throw UnsupportedError('Request Content-Type header is not multipart');
    }

    final boundary = contentType.parameters['boundary'];

    if (boundary == null) {
      throw UnsupportedError('Request Content-Type header is not multipart');
    }

    return MimeMultipartTransformer(boundary).bind(this).map((part) => Multipart(part));
  }

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return body.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

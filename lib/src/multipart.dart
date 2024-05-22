import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class Multipart extends MimeMultipart {
  final MimeMultipart _inner;

  @override
  final Map<String, String> headers;

  late final MediaType? _contentType = switch (headers['content-type'] != null) {
    true => MediaType.parse(headers['content-type']!),
    false => null,
  };

  Encoding? get _encoding {
    var contentType = _contentType;
    if (contentType == null) return null;
    if (!contentType.parameters.containsKey('charset')) return null;
    return Encoding.getByName(contentType.parameters['charset']);
  }

  Multipart(this._inner) : headers = CaseInsensitiveMap.from(_inner.headers);

  /// Gets the filename from the content-disposition header.
  String? get filename {
    final contentDisposition = headers['content-disposition'];
    if (contentDisposition == null) return null;
    final match = RegExp(r'filename="(.+?)"').firstMatch(contentDisposition);
    if (match == null) return null;
    return match.group(1);
  }

  /// Gets the name from the content-disposition header.
  String get name {
    final contentDisposition = headers['content-disposition'];
    if (contentDisposition == null) return '';
    final match = RegExp(r'name="(.+?)"').firstMatch(contentDisposition);
    if (match == null) return '';
    return match.group(1) ?? '';
  }

  /// Gets the mime type from the content-type header.
  String get mimeType {
    final contentType = headers['content-type'];
    if (contentType == null) return 'text/plain';
    return contentType;
  }

  /// Gets the content as a [Uint8List].
  ///
  /// If [lengthInBytes] is provided and the file size in bytes is larger, an ArgumentError will be thrown.
  ///
  /// Throws an [ArgumentError] if the file is too large.
  Future<Uint8List> asUint8List([int lengthInBytes = -1]) async {
    final List<List<int>> chunks = <List<int>>[];
    await for (final part in _inner) {
      chunks.add(part);
      if (!lengthInBytes.isNegative) {
        if (Uint8List.fromList(chunks.expand((element) => element).toList()).lengthInBytes > lengthInBytes) {
          throw ArgumentError('File too large, maximum allowed size is $lengthInBytes bytes');
        }
      }
    }
    return Uint8List.fromList(chunks.expand((element) => element).toList());
  }

  /// Gets the content as a [String].
  Future<String> asString([Encoding? encoding]) async {
    encoding ??= _encoding ?? utf8;
    return encoding.decodeStream(this);
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _inner.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

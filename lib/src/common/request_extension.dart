import 'dart:convert';

import 'package:shelf/shelf.dart';

extension RequestExtension on Request {
  Future<Map<String, dynamic>> readAsJson() async {
    try {
      final contentType = headers['content-type'];

      final contetnLength = headers['content-length'];

      if (contetnLength == null) {
        return {};
      }

      if (int.tryParse(contetnLength) == null) {
        return {};
      }

      if (int.parse(contetnLength) == 0) {
        return {};
      }

      if (contentType == null || !contentType.contains('application/json')) {
        return {};
      }

      return json.decode(await readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}

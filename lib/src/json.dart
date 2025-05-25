import 'dart:convert';

import 'package:shelf/shelf.dart';

class Json extends Response {
  Json._(
    super.statusCode, {
    super.body,
    super.headers,
    super.context,
    super.encoding,
  });

  factory Json(
    int statusCode, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json._(
      statusCode,
      body: switch (body != null) {
        true => json.encode(body),
        false => null,
      },
      headers: {
        'Content-Type': 'application/json',
        'x-powered-by': 'https://github.com/tihrasguinho/request_mapper.git',
        ...?headers,
      },
      context: context,
      encoding: utf8,
    );
  }

  factory Json.ok({
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(200, body: body, headers: headers, context: context);
  }

  factory Json.created({
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(201, body: body, headers: headers, context: context);
  }

  factory Json.noContent({
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(204, body: body, headers: headers, context: context);
  }

  factory Json.badRequest({
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(400, body: body, headers: headers, context: context);
  }

  factory Json.unauthorized({
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(401, body: body, headers: headers, context: context);
  }

  factory Json.forbidden({
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(403, body: body, headers: headers, context: context);
  }

  factory Json.notFound({
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(404, body: body, headers: headers, context: context);
  }

  factory Json.methodNotAllowed({
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(405, body: body, headers: headers, context: context);
  }

  factory Json.conflict({
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(409, body: body, headers: headers, context: context);
  }

  factory Json.internalServerError({
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(500, body: body, headers: headers, context: context);
  }

  factory Json.serviceUnavailable({
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) {
    return Json(503, body: body, headers: headers, context: context);
  }
}

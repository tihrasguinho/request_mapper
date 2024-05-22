import 'dart:convert';
import 'dart:io' as io;

import 'package:request_mapper/src/request.dart';

import 'connection.dart';
import 'controller.dart';
import 'group.dart';
import 'handler.dart';
import 'method.dart';
import 'response.dart';

class Mapper {
  final Group _group;

  const Mapper._(this._group);

  Mapper() : this._(Group());

  /// Adds a new route to the mapper.
  void add(String path, Method method, Handler handler) {
    return _group.add(path, method, handler);
  }

  /// Adds a new [GET] route to the mapper.
  void get(String path, Handler handler) {
    return _group.get(path, handler);
  }

  /// Adds a new [POST] route to the mapper.
  void post(String path, Handler handler) {
    return _group.post(path, handler);
  }

  /// Adds a new [PUT] route to the mapper.
  void put(String path, Handler handler) {
    return _group.put(path, handler);
  }

  /// Adds a new [DELETE] route to the mapper.
  void delete(String path, Handler handler) {
    return _group.delete(path, handler);
  }

  /// Adds a new [PATCH] route to the mapper.
  void patch(String path, Handler handler) {
    return _group.patch(path, handler);
  }

  /// Adds a new [HEAD] route to the mapper.
  void head(String path, Handler handler) {
    return _group.head(path, handler);
  }

  /// Adds a new [OPTIONS] route to the mapper.
  void options(String path, Handler handler) {
    return _group.options(path, handler);
  }

  /// Adds a new [TRACE] route to the mapper.
  void trace(String path, Handler handler) {
    return _group.trace(path, handler);
  }

  /// Attaches a controller to the mapper.
  void controller(Controller controller) {
    return _group.merge(controller);
  }

  /// Adds a new WebSocket route to the mapper.
  void webSocket(String path, void Function(Connection channel) handler) {
    assert(() {
      if (!path.endsWith('/ws')) {
        throw Exception('WebSocket path must end with `/ws`');
      }
      return true;
    }());
    return _group.add(path, Get(), handler);
  }

  /// Starts the server, listening on [address] and [port].
  Future<void> start({Object? address, int? port}) async {
    final server = await io.HttpServer.bind(address ?? '0.0.0.0', port ?? 8080);
    server.listen(
      (request) async {
        for (final entry in _group.entries) {
          if (entry.path.endsWith('/ws') && entry.pathMatches(request)) {
            final webSocket = await io.WebSocketTransformer.upgrade(request);

            return entry.handler(Connection(webSocket));
          }
          if (entry.pathMatches(request) && entry.methodMatches(request)) {
            return entry.handler(
              switch (entry.hasPathParameters()) {
                true => Request.fromHttpRequest(request).copy(pathParameters: entry.getPathParameters(request)),
                false => Request.fromHttpRequest(request),
              },
              Response((statusCode, {body, headers}) async {
                return await request.send(
                  statusCode,
                  body: body,
                  headers: headers,
                );
              }),
            );
          }
        }

        return request.send(
          404,
          headers: {io.HttpHeaders.contentTypeHeader: 'text/plain'},
          body: 'Not found',
        );
      },
    );
  }
}

extension _HttpRequestExt on io.HttpRequest {
  Future<void> send(
    int statusCode, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    response.statusCode = statusCode;
    headers?.forEach((key, value) => response.headers.set(key, value));
    if (body is String) {
      response.write(body);
    } else if (body is List<int>) {
      response.add(body);
    } else if (body is Map<String, dynamic>) {
      response.write(json.encode(body));
    } else if (body is Stream<List<int>>) {
      await for (final chunk in body) {
        response.add(chunk);
      }
    }
    await response.close();
  }
}

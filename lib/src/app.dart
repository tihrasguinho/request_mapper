import 'dart:io';

import 'package:request_mapper/src/method.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

final RegExp _pathRegex = RegExp(
    r'^\/(?!.*\/\/)(?:(?:[a-zA-Z0-9._\-]+|<[^<>|]+(?:\|[^<>]+)?>)(?:\/(?:[a-zA-Z0-9._\-]+|<[^<>|]+(?:\|[^<>]+)?>))*)?$');

abstract interface class App {
  factory App({String? prefix}) => AppImp(prefix: prefix);
  void add(String path, Method method, Handler handler);
  void get(String path, Function handler);
  void post(String path, Function handler);
  void put(String path, Function handler);
  void delete(String path, Function handler);
  void patch(String path, Function handler);
  void head(String path, Function handler);
  void options(String path, Function handler);
  void trace(String path, Function handler);
  void controller(Controller controller);
  void middleware(Middleware middleware);
  Future<HttpServer> start({Object? address, int? port});
}

class AppImp implements App {
  final String? prefix;
  final Router _router = Router();
  final List<Middleware> _middlewares = [];

  AppImp({this.prefix});

  @override
  void add(String path, Method method, Function handler) {
    if (!_pathRegex.hasMatch(path)) {
      throw ArgumentError('Invalid path');
    }

    if (prefix == null) {
      return _router.add(method.verb, path, handler);
    }

    if (!_pathRegex.hasMatch(prefix!)) {
      throw ArgumentError('Invalid prefix');
    }

    final joinedPath = '$prefix$path';

    final normalizedPath = switch (joinedPath.endsWith('/')) {
      true => joinedPath.substring(0, joinedPath.length - 1),
      false => joinedPath,
    };

    return _router.add(method.verb, normalizedPath, handler);
  }

  @override
  void delete(String path, Function handler) {
    return add(path, Delete(), handler);
  }

  @override
  void get(String path, Function handler) {
    return add(path, Get(), handler);
  }

  @override
  void head(String path, Function handler) {
    return add(path, Head(), handler);
  }

  @override
  void options(String path, Function handler) {
    return add(path, Options(), handler);
  }

  @override
  void patch(String path, Function handler) {
    return add(path, Patch(), handler);
  }

  @override
  void post(String path, Function handler) {
    return add(path, Post(), handler);
  }

  @override
  void put(String path, Function handler) {
    return add(path, Put(), handler);
  }

  @override
  void trace(String path, Function handler) {
    return add(path, Trace(), handler);
  }

  @override
  void controller(Controller controller) {
    if (prefix == null) {
      return _router.mount(controller._prefix, controller.handler);
    }

    if (!_pathRegex.hasMatch(prefix!)) {
      throw ArgumentError('Invalid prefix');
    }

    final joinedPath = '$prefix${controller._prefix}';

    final normalizedPath = switch (joinedPath.endsWith('/')) {
      true => joinedPath.substring(0, joinedPath.length - 1),
      false => joinedPath,
    };

    return _router.mount(normalizedPath, controller.handler);
  }

  @override
  void middleware(Middleware middleware) {
    return _middlewares.add(middleware);
  }

  @override
  Future<HttpServer> start({Object? address, int? port}) async {
    final pipeline = _middlewares.fold(Pipeline(), (p, m) => p.addMiddleware(m));

    final handler = pipeline.addHandler(_router.call);

    return await io.serve(handler.call, address ?? '0.0.0.0', port ?? 8080);
  }
}

abstract class Controller {
  final String _prefix;
  final Router _router;
  final List<Middleware> _middlewares;

  Controller(this._prefix, {List<Middleware>? middlewares})
      : _router = Router(),
        _middlewares = middlewares ?? [];

  void add(String path, Method method, Function handler) {
    if (!_pathRegex.hasMatch(path)) {
      throw ArgumentError('Invalid path');
    }

    if (!_pathRegex.hasMatch(_prefix)) {
      throw ArgumentError('Invalid prefix');
    }

    return _router.add(method.verb, path, handler);
  }

  void get(String path, Function handler) {
    return add(path, Get(), handler);
  }

  void post(String path, Function handler) {
    return add(path, Post(), handler);
  }

  void put(String path, Function handler) {
    return add(path, Put(), handler);
  }

  void delete(String path, Function handler) {
    return add(path, Delete(), handler);
  }

  void patch(String path, Function handler) {
    return add(path, Patch(), handler);
  }

  void head(String path, Function handler) {
    return add(path, Head(), handler);
  }

  void options(String path, Function handler) {
    return add(path, Options(), handler);
  }

  void trace(String path, Function handler) {
    return add(path, Trace(), handler);
  }

  void middleware(Middleware middleware) {
    return _middlewares.add(middleware);
  }

  Handler get handler {
    return _middlewares.fold(Pipeline(), (p, m) => p.addMiddleware(m)).addHandler(_router.call);
  }
}

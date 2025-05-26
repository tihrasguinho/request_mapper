import 'dart:io';

import 'package:request_mapper/src/common/method.dart';
import 'package:shelf/shelf.dart' show Middleware, Pipeline;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'common/not_found_handler.dart';
import 'common/regexes.dart';
import 'interfaces/app.dart';
import 'interfaces/controller.dart';

class AppImp implements App {
  final String? prefix;
  final Router _router = Router(notFoundHandler: notFoundHandler());
  final List<Middleware> _middlewares = [];

  AppImp({this.prefix});

  @override
  void add(Method method, String path, Function handler) {
    if (!pathRegex.hasMatch(path)) {
      throw ArgumentError('Invalid path');
    }

    if (prefix == null) {
      return _router.add(method.verb, path, handler);
    }

    if (!pathRegex.hasMatch(prefix!)) {
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
    return add(Delete(), path, handler);
  }

  @override
  void get(String path, Function handler) {
    return add(Get(), path, handler);
  }

  @override
  void head(String path, Function handler) {
    return add(Head(), path, handler);
  }

  @override
  void options(String path, Function handler) {
    return add(Options(), path, handler);
  }

  @override
  void patch(String path, Function handler) {
    return add(Patch(), path, handler);
  }

  @override
  void post(String path, Function handler) {
    return add(Post(), path, handler);
  }

  @override
  void put(String path, Function handler) {
    return add(Put(), path, handler);
  }

  @override
  void trace(String path, Function handler) {
    return add(Trace(), path, handler);
  }

  @override
  void controller(Controller controller) {
    if (prefix == null) {
      return _router.mount(controller.prefix, controller.handler);
    }

    if (!pathRegex.hasMatch(prefix!)) {
      throw ArgumentError('Invalid prefix');
    }

    final joinedPath = '$prefix${controller.prefix}';

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

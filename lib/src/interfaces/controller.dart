import 'package:request_mapper/request_mapper.dart';
import 'package:shelf_router/shelf_router.dart';

import '../common/not_found_handler.dart';

abstract class Controller {
  final String prefix;
  final Router _router;
  final List<Middleware> _middlewares;

  Controller(this.prefix)
      : _router = Router(notFoundHandler: notFoundHandler()),
        _middlewares = [] {
    setup(Register(_router, _middlewares));
  }

  // void add(String path, Method method, Function handler) {
  //   if (!pathRegex.hasMatch(path)) {
  //     throw ArgumentError('Invalid path');
  //   }

  //   if (!pathRegex.hasMatch(prefix)) {
  //     throw ArgumentError('Invalid prefix');
  //   }

  //   return _router.add(method.verb, path, handler);
  // }

  // void get(String path, Function handler) {
  //   return add(path, Get(), handler);
  // }

  // void post(String path, Function handler) {
  //   return add(path, Post(), handler);
  // }

  // void put(String path, Function handler) {
  //   return add(path, Put(), handler);
  // }

  // void delete(String path, Function handler) {
  //   return add(path, Delete(), handler);
  // }

  // void patch(String path, Function handler) {
  //   return add(path, Patch(), handler);
  // }

  // void head(String path, Function handler) {
  //   return add(path, Head(), handler);
  // }

  // void options(String path, Function handler) {
  //   return add(path, Options(), handler);
  // }

  // void trace(String path, Function handler) {
  //   return add(path, Trace(), handler);
  // }

  // void middleware(Middleware middleware) {
  //   return _middlewares.add(middleware);
  // }

  void setup(Register register);

  Handler get handler {
    return _middlewares.fold(Pipeline(), (p, m) => p.addMiddleware(m)).addHandler(_router.call);
  }
}

class Register {
  final Router router;
  final List<Middleware> middlewares;

  const Register(this.router, this.middlewares);

  void middleware(Middleware middleware) {
    return middlewares.add(middleware);
  }

  void add(Method method, String route, Function handler) {
    return router.add(method.verb, route, handler);
  }

  void get(String route, Function handler) => add(Get(), route, handler);

  void post(String route, Function handler) => add(Post(), route, handler);

  void put(String route, Function handler) => add(Put(), route, handler);

  void delete(String route, Function handler) => add(Delete(), route, handler);

  void patch(String route, Function handler) => add(Patch(), route, handler);

  void head(String route, Function handler) => add(Head(), route, handler);

  void options(String route, Function handler) => add(Options(), route, handler);

  void trace(String route, Function handler) => add(Trace(), route, handler);

  void mount(String route, Handler handler) => router.mount(route, handler);
}

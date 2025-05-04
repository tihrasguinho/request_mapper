import 'dart:io' as io;

import 'method.dart';

class Entry {
  final String path;
  final Method method;
  final Function handler;

  const Entry(this.path, this.method, this.handler);

  /// Checks if the request matches the entry.
  bool pathMatches(io.HttpRequest request) {
    if (path.split('/').length != request.requestedUri.path.split('/').length) {
      return false;
    }

    final parts = path.split('/');

    for (var i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (RegExp(r'{.+}').hasMatch(part)) {
        final name = part.substring(1, part.length - 1);
        final value = request.requestedUri.path.split('/')[i];
        if (value.isEmpty) return false;
        if (name.contains('|') && name.split('|').every((p) => p.isNotEmpty)) {
          final pattern = name.split('|')[1];
          if (!RegExp('^$pattern\$').hasMatch(value)) return false;
          return true;
        } else {
          return true;
        }
      }

      if (part != request.requestedUri.path.split('/')[i]) {
        return false;
      }
    }
    return true;
  }

  /// Checks if the request method matches the entry.
  bool methodMatches(io.HttpRequest request) {
    return method() == Method.fromVerb(request.method)();
  }

  /// Checks if the entry has path parameters.
  bool hasPathParameters() {
    return RegExp(r'{.+}').hasMatch(path);
  }

  /// Gets the path parameters from the request.
  Map<String, String> getPathParameters(io.HttpRequest request) {
    final params = <String, String>{};
    final parts = path.split('/');
    for (var i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (RegExp(r'{.+}').hasMatch(part)) {
        final name = part.substring(1, part.length - 1);
        final value = request.requestedUri.path.split('/')[i];
        if (value.isEmpty) continue;
        if (name.contains('|') && name.split('|').every((p) => p.isNotEmpty)) {
          final pattern = name.split('|')[1];
          if (!RegExp(pattern).hasMatch(value)) continue;
          params[name.split('|')[0]] = value;
        } else {
          params[name] = value;
        }
      }
    }
    return params;
  }
}

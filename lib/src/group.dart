import 'connection.dart';
import 'entry.dart';
import 'method.dart';

class Group {
  final List<Entry> entries;
  final String? prefix;

  const Group._(this.entries, this.prefix);

  Group([String? prefix]) : this._([], prefix);

  /// Adds a new route to the group.
  void add(String path, Method method, Function handler) {
    assert(() {
      if (prefix != null && !prefix!.startsWith('/')) {
        throw ArgumentError('Group prefix must start with /');
      }

      if (prefix != null && prefix != '/' && prefix!.endsWith('/')) {
        throw ArgumentError('Group prefix must not end with /');
      }

      if (!path.startsWith('/')) {
        throw ArgumentError('Route path must start with /');
      }

      if (path != '/' && path.endsWith('/')) {
        throw ArgumentError('Route path must not end with /');
      }

      return true;
    }());
    var joinedPath = (prefix ?? '') + path;

    if (joinedPath != '/' && joinedPath.endsWith('/')) {
      joinedPath = joinedPath.substring(0, joinedPath.length - 1);
    }

    return entries.add(Entry(joinedPath, method, handler));
  }

  /// Adds a new GET route to the group.
  void get(String path, Function handler) {
    return add(path, Get(), handler);
  }

  /// Adds a new POST route to the group.
  void post(String path, Function handler) {
    return add(path, Post(), handler);
  }

  /// Adds a new PUT route to the group.
  void put(String path, Function handler) {
    return add(path, Put(), handler);
  }

  /// Adds a new DELETE route to the group.
  void delete(String path, Function handler) {
    return add(path, Delete(), handler);
  }

  /// Adds a new PATCH route to the group.
  void patch(String path, Function handler) {
    return add(path, Patch(), handler);
  }

  /// Adds a new HEAD route to the group.
  void head(String path, Function handler) {
    return add(path, Head(), handler);
  }

  /// Adds a new OPTIONS route to the group.
  void options(String path, Function handler) {
    return add(path, Options(), handler);
  }

  /// Adds a new TRACE route to the group.
  void trace(String path, Function handler) {
    return add(path, Trace(), handler);
  }

  /// Adds a new CONNECT route to the group.
  void connect(String path, Function handler) {
    return add(path, Connect(), handler);
  }

  /// Adds a new WebSocket route to the group.
  void webSocket(String path, void Function(Connection connection) handler) {
    assert(() {
      if (!path.endsWith('/ws')) {
        throw Exception('WebSocket path must end with `/ws`');
      }
      return true;
    }());
    return add(path, Get(), handler);
  }

  /// Merges another [Group] into this one.
  void merge(Group group) {
    entries.addAll(group.entries);
  }
}

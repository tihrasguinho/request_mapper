sealed class Method {
  final String verb;

  const Method(this.verb);

  String call() => verb;

  factory Method.fromVerb(String verb) {
    return switch (verb) {
      'GET' => const Get(),
      'POST' => const Post(),
      'PUT' => const Put(),
      'DELETE' => const Delete(),
      'PATCH' => const Patch(),
      'HEAD' => const Head(),
      'OPTIONS' => const Options(),
      'TRACE' => const Trace(),
      'CONNECT' => const Connect(),
      _ => throw ArgumentError('Unknown verb: $verb'),
    };
  }
}

final class Get extends Method {
  const Get() : super('GET');
}

final class Post extends Method {
  const Post() : super('POST');
}

final class Put extends Method {
  const Put() : super('PUT');
}

final class Delete extends Method {
  const Delete() : super('DELETE');
}

final class Patch extends Method {
  const Patch() : super('PATCH');
}

final class Head extends Method {
  const Head() : super('HEAD');
}

final class Options extends Method {
  const Options() : super('OPTIONS');
}

final class Trace extends Method {
  const Trace() : super('TRACE');
}

final class Connect extends Method {
  const Connect() : super('CONNECT');
}

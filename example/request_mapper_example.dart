import 'package:request_mapper/request_mapper.dart';

void main() async {
  final mapper = Mapper();

  mapper.get('/', root);

  mapper.post('/upload', (req, res) async {
    if (req.multipart) {
      await for (final part in req.parts) {
        if (part.filename != null) {
          final bytes = await part.asUint8List();
          print([part.name, part.filename, part.mimeType, bytes.lengthInBytes]);
        } else {
          final string = await part.asString();
          print(string);
        }
      }
    }
    return res.json(200);
  });

  mapper.controller(UsersController('/users'));

  mapper.controller(WebSocketController('/websocket'));

  await mapper.start();
}

void root(Request req, Response res) {
  return res.json(
    200,
    body: {
      'message': 'Current Timestamp is ${DateTime.now().toIso8601String()}',
    },
  );
}

abstract class Entity {
  List get props;

  @override
  String toString() {
    return '$runtimeType => ${props.join(',')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! Entity) return false;

    final listEquals = (List a, List b) {
      if (a.length != b.length) return false;

      for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }

      return true;
    }(other.props, props);

    return listEquals;
  }

  @override
  int get hashCode => Object.hashAll(props);
}

class User extends Entity {
  final int id;
  final String name;
  final int age;

  User({required this.id, required this.name, required this.age});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'age': age};
  }

  User copyWith({int? id, String? name, int? age}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }

  @override
  List get props => [id, name, age];
}

class UsersController extends Controller {
  final List<User> _users = [];

  UsersController(super.prefix) {
    post('/', _create);
    get('/', _getUsers);
    get('/{id}', _getUser);
    put('/{id}', _update);
    delete('/{id}', _delete);
  }

  void _create(Request req, Response response) async {
    final body = await req.readMap();

    final user = User(
      id: _users.length + 1,
      name: body['name'],
      age: body['age'],
    );

    _users.add(user);

    return response.json(
      201,
      body: {
        'user': user.toMap(),
      },
    );
  }

  void _getUsers(Request req, Response response) async {
    return response.json(
      200,
      body: {
        'users': _users.map((user) => user.toMap()).toList(),
      },
    );
  }

  void _getUser(Request req, Response response) async {
    final id = int.parse(req.pathParameters['id']!);

    if (!_users.any((user) => user.id == id)) {
      return response.json(404, body: {'error': 'User not found'});
    }

    return response.json(
      200,
      body: {
        'user': _users.firstWhere((user) => user.id == id).toMap(),
      },
    );
  }

  void _update(Request req, Response response) async {
    final id = int.parse(req.pathParameters['id']!);

    if (!_users.any((user) => user.id == id)) {
      return response.json(404, body: {'error': 'User not found'});
    }

    final body = await req.readMap();

    final user = _users.firstWhere((user) => user.id == id);

    _users[_users.indexOf(user)] = user.copyWith(
      name: body['name'] ?? user.name,
      age: body['age'] ?? user.age,
    );

    return response.json(
      200,
      body: {
        'user': _users.firstWhere((user) => user.id == id).toMap(),
      },
    );
  }

  void _delete(Request req, Response response) async {
    final id = int.parse(req.pathParameters['id']!);

    if (!_users.any((user) => user.id == id)) {
      return response.json(404, body: {'error': 'User not found'});
    }

    _users.removeWhere((user) => user.id == id);

    return response.json(
      200,
      body: {
        'message': 'User deleted successfully',
      },
    );
  }
}

class WebSocketController extends Controller {
  final List<Connection> connections = [];
  WebSocketController(super.prefix) {
    webSocket(
      '/ws',
      (connection) async {
        connections.add(connection);
        await for (final event in connection.events) {
          print(event);
        }
        connection.send(
          ConnectionEvent.onConnected(
            {
              'message': 'Welcome to WebSocket',
              'id': connection.id,
            },
          ),
        );
      },
    );
  }
}

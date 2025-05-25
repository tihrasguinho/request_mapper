import 'package:request_mapper/request_mapper.dart';

void main() async {
  final app = App(prefix: '/api/v1');

  app.get('/', (_) => Response(200, body: 'Hello, World!'));

  app.controller(AuthController());

  app.middleware(logRequests());

  final server = await app.start();

  print('Listening on http://${server.address.host}:${server.port}');
}

class AuthController extends Controller {
  AuthController() : super('/auth') {
    get('/', (request) => Response(200, body: 'auth'));
    get('/sign-in', (request) => Response(200, body: 'sign in'));
    get(r'/user/<id|[\d]+>', (Request request, String id) => Response(200, body: 'user id $id'));
  }
}

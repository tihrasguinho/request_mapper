import 'package:request_mapper/src/common/json.dart';
import 'package:shelf/shelf.dart';

Handler notFoundHandler() {
  return (request) => Json.notFound(
        body: {'error': 'Route not found!'},
      );
}

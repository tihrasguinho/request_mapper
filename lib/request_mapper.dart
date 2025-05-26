library request_mapper;

import 'src/app.dart';
import 'src/interfaces/app.dart';

export 'package:shelf/shelf.dart';

export 'src/app.dart';
export 'src/common/json.dart';
export 'src/common/method.dart';
export 'src/common/regexes.dart';
export 'src/common/request_extension.dart';
export 'src/interfaces/controller.dart';

App createApp({String? prefix}) => AppImp(prefix: prefix);

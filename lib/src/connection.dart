import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Connection extends IOWebSocketChannel implements WebSocketChannel {
  late final String id;
  late final DateTime connectionTime;

  Connection(super.webSocket) {
    connectionTime = DateTime.now();
    id = _randomStr(connectionTime);
  }

  Stream<ConnectionEvent> get events => stream.map(_map);

  void send(ConnectionEvent event) {
    return sink.add(event.toJson());
  }

  ConnectionEvent _map(dynamic event) {
    if (event is String) {
      Map<String, dynamic> data;
      try {
        data = Map<String, dynamic>.from(jsonDecode(event));
      } catch (_) {
        return ConnectionEvent.onUnknown();
      }
      if (!data.containsKey('event')) {
        return ConnectionEvent.onUnknown();
      }
      return ConnectionEvent(
        event: data['event'],
        data: data['data'] ?? {},
      );
    }
    return ConnectionEvent.onUnknown();
  }

  String _randomStr(DateTime connectionTime) {
    final random = Random(connectionTime.millisecond);
    final chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(16, (index) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Connection) return false;
    return id == other.id && connectionTime == other.connectionTime;
  }

  @override
  int get hashCode => super.hashCode ^ id.hashCode ^ connectionTime.hashCode;
}

class ConnectionEvent {
  static const String connected = 'connected';
  static const String disconnected = 'disconnected';
  static const String unknown = 'unknown';

  final String event;
  final Map<String, dynamic> data;
  late final DateTime createdAt;

  ConnectionEvent({required this.event, required this.data}) {
    createdAt = DateTime.now();
  }

  ConnectionEvent.onConnected(Map<String, dynamic> data) : this(event: connected, data: data);

  ConnectionEvent.onDisconnected(Map<String, dynamic> data) : this(event: disconnected, data: data);

  ConnectionEvent.onUnknown() : this(event: unknown, data: const {});

  @override
  String toString() {
    return 'ConnectionEvent{event: $event, data: $data, createdAt: $createdAt}';
  }

  String toJson() => jsonEncode(
        {
          'event': event,
          'data': data,
        },
      );

  @override
  bool operator ==(covariant ConnectionEvent other) {
    if (identical(this, other)) return true;
    mapEquals(Map a, Map b) {
      if (a.length != b.length) return false;
      for (final entry in a.entries) {
        if (b.containsKey(entry.key)) return false;
        if (b[entry.key] != entry.value) return false;
      }
      return true;
    }

    return other.event == event && mapEquals(other.data, data);
  }

  @override
  int get hashCode => event.hashCode ^ data.hashCode;
}

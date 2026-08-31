import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../services/api_service.dart';

/// One message in a conversation.
class ChatMessage {
  final String id;
  final String from;
  final String to;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;

  /// Set when this device sent it and the server has not confirmed yet. The
  /// message shows immediately with a pending mark rather than the input
  /// appearing to do nothing while the round trip happens.
  final bool pending;

  /// Set when the send was refused. Shown as failed rather than silently
  /// vanishing, which would leave somebody believing they had sent it.
  final bool failed;

  const ChatMessage({
    required this.id,
    required this.from,
    required this.to,
    required this.body,
    required this.createdAt,
    this.readAt,
    this.pending = false,
    this.failed = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: '${json['_id'] ?? ''}',
        from: '${json['from'] ?? ''}',
        to: '${json['to'] ?? ''}',
        body: '${json['body'] ?? ''}',
        createdAt:
            DateTime.tryParse('${json['createdAt'] ?? ''}') ?? DateTime.now(),
        readAt: DateTime.tryParse('${json['readAt'] ?? ''}'),
      );

  ChatMessage copyWith({String? id, bool? pending, bool? failed, DateTime? readAt}) =>
      ChatMessage(
        id: id ?? this.id,
        from: from,
        to: to,
        body: body,
        createdAt: createdAt,
        readAt: readAt ?? this.readAt,
        pending: pending ?? this.pending,
        failed: failed ?? this.failed,
      );
}

/// A conversation as it appears in a list.
class ChatConversation {
  final String withUserId;
  final String withName;
  final String withRole;
  final String lastMessage;
  final DateTime? lastAt;
  final bool lastFromMe;
  final int unread;

  const ChatConversation({
    required this.withUserId,
    required this.withName,
    required this.withRole,
    required this.lastMessage,
    required this.lastAt,
    required this.lastFromMe,
    required this.unread,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) =>
      ChatConversation(
        withUserId: '${json['withUserId'] ?? ''}',
        withName: '${json['withName'] ?? 'Unknown'}',
        withRole: '${json['withRole'] ?? ''}',
        lastMessage: '${json['lastMessage'] ?? ''}',
        lastAt: DateTime.tryParse('${json['lastAt'] ?? ''}'),
        lastFromMe: json['lastFromMe'] == true,
        unread: json['unread'] is num ? (json['unread'] as num).toInt() : 0,
      );
}

/// The live chat connection.
///
/// One socket for the whole app, shared by every screen. The identity comes
/// from the auth token on the handshake — the server never accepts a user id
/// from the client, so there is nothing to pass in here.
class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  io.Socket? _socket;

  final ValueNotifier<bool> isConnected = ValueNotifier(false);

  /// The signed-in user's own id, as the server resolved it.
  String? myUserId;

  final _incoming = StreamController<ChatMessage>.broadcast();
  final _read = StreamController<String>.broadcast();
  final _presence = StreamController<MapEntry<String, bool>>.broadcast();

  /// Messages arriving from anyone. A screen filters to its own conversation.
  Stream<ChatMessage> get onMessage => _incoming.stream;

  /// The id of someone who just read what you sent them.
  Stream<String> get onRead => _read.stream;

  Stream<MapEntry<String, bool>> get onPresence => _presence.stream;

  bool get connected => _socket?.connected == true;

  /// Opens the connection. Safe to call repeatedly — a second call while
  /// already connected does nothing.
  Future<void> connect() async {
    if (_socket != null) return;

    final token = ApiService().authToken;
    if (token == null || token.isEmpty) {
      debugPrint('[CHAT] not signed in, staying disconnected');
      return;
    }

    // The socket lives on the same host as the API. Deriving it means one
    // place to change when the backend moves, and no chance of the two
    // pointing at different deployments.
    final origin = ApiService.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');

    final socket = io.io(
      origin,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionDelay(2000)
          .build(),
    );

    socket.onConnect((_) => debugPrint('[CHAT] connected'));
    socket.on('ready', (data) {
      if (data is Map) myUserId = '${data['userId'] ?? ''}';
      isConnected.value = true;
    });
    socket.onDisconnect((_) {
      isConnected.value = false;
      debugPrint('[CHAT] disconnected');
    });
    socket.onConnectError((e) {
      isConnected.value = false;
      // A refused handshake means the token is stale or the account is
      // disabled — worth seeing in the log, never worth a crash.
      debugPrint('[CHAT] could not connect: $e');
    });

    socket.on('new-message', (data) {
      if (data is Map) {
        _incoming.add(ChatMessage.fromJson(Map<String, dynamic>.from(data)));
      }
    });
    socket.on('messages-read', (data) {
      if (data is Map) _read.add('${data['byUserId'] ?? ''}');
    });
    socket.on('presence', (data) {
      if (data is Map) {
        _presence.add(MapEntry('${data['userId']}', data['online'] == true));
      }
    });

    _socket = socket;
  }

  /// Sends a message and waits for the server to confirm it.
  ///
  /// Returns the stored message, or null with [onError] called — the caller
  /// marks its optimistic copy as failed rather than leaving it looking sent.
  Future<ChatMessage?> send({
    required String toUserId,
    required String body,
    void Function(String reason)? onError,
  }) async {
    final socket = _socket;
    if (socket == null || !socket.connected) {
      onError?.call('Not connected. Check your connection and try again.');
      return null;
    }

    final completer = Completer<ChatMessage?>();
    socket.emitWithAck(
      'send-message',
      {'toUserId': toUserId, 'body': body},
      ack: (response) {
        if (completer.isCompleted) return;
        if (response is Map && response['ok'] == true && response['message'] is Map) {
          completer.complete(
              ChatMessage.fromJson(Map<String, dynamic>.from(response['message'] as Map)));
        } else {
          final reason = response is Map ? '${response['error'] ?? ''}' : '';
          onError?.call(reason.isEmpty ? 'The message could not be sent.' : reason);
          completer.complete(null);
        }
      },
    );

    // A socket that never acknowledges would otherwise leave the message
    // spinning for ever.
    return completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () {
        onError?.call('The server did not answer. The message was not sent.');
        return null;
      },
    );
  }

  void markRead(String withUserId) {
    _socket?.emit('mark-read', {'withUserId': withUserId});
  }

  void setTyping(String toUserId, bool typing) {
    _socket?.emit('typing', {'toUserId': toUserId, 'typing': typing});
  }

  // ── History, over the REST API ────────────────────────────

  Future<List<ChatConversation>> conversations() async {
    final response = await ApiService().get('/chat/conversations');
    if (!response.success || response.data is! Map) return const [];
    final raw = (response.data as Map)['items'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => ChatConversation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<ChatMessage>> history(String withUserId) async {
    final response = await ApiService().get('/chat/messages/$withUserId');
    if (!response.success || response.data is! Map) return const [];
    final raw = (response.data as Map)['items'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<int> unreadCount() async {
    final response = await ApiService().get('/chat/unread');
    if (!response.success || response.data is! Map) return 0;
    final value = (response.data as Map)['unread'];
    return value is num ? value.toInt() : 0;
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
    myUserId = null;
  }
}

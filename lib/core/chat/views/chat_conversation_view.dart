import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../chat_service.dart';

/// One conversation.
///
/// Shared by the customer and merchant apps rather than written twice: the
/// screen is identical from both sides, and two copies would drift the moment
/// one of them got a fix.
class ChatConversationView extends StatefulWidget {
  final String withUserId;
  final String withName;

  /// Each app passes its own brand colour; nothing else differs.
  final Color accent;

  const ChatConversationView({
    super.key,
    required this.withUserId,
    required this.withName,
    this.accent = const Color(0xFF1B7A43),
  });

  @override
  State<ChatConversationView> createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<ChatConversationView> {
  final ChatService _chat = ChatService();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<ChatMessage> _messages = [];
  StreamSubscription<ChatMessage>? _incoming;
  StreamSubscription<String>? _read;

  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    await _chat.connect();

    // What was said before this screen opened. Without it a conversation with
    // history opens blank, which reads as the messages having been lost.
    final history = await _chat.history(widget.withUserId);
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(history);
      _loading = false;
    });
    _jumpToLatest();

    _chat.markRead(widget.withUserId);

    _incoming = _chat.onMessage.listen((message) {
      // The stream carries every conversation; this screen owns one.
      final isThisConversation = message.from == widget.withUserId ||
          message.to == widget.withUserId;
      if (!isThisConversation || !mounted) return;
      setState(() => _messages.add(message));
      _jumpToLatest();
      // Arriving while the screen is open means it has been seen.
      if (message.from == widget.withUserId) _chat.markRead(widget.withUserId);
    });

    _read = _chat.onRead.listen((byUserId) {
      if (byUserId != widget.withUserId || !mounted) return;
      setState(() {
        for (var i = 0; i < _messages.length; i++) {
          if (_isMine(_messages[i]) && _messages[i].readAt == null) {
            _messages[i] = _messages[i].copyWith(readAt: DateTime.now());
          }
        }
      });
    });
  }

  bool _isMine(ChatMessage m) => m.from == _chat.myUserId;

  void _jumpToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final body = _input.text.trim();
    if (body.isEmpty || _sending) return;

    // Shown straight away with a pending mark. Waiting for the round trip
    // before drawing anything makes the input look broken on a slow line.
    final optimistic = ChatMessage(
      id: 'pending-${DateTime.now().microsecondsSinceEpoch}',
      from: _chat.myUserId ?? '',
      to: widget.withUserId,
      body: body,
      createdAt: DateTime.now(),
      pending: true,
    );
    setState(() {
      _messages.add(optimistic);
      _sending = true;
    });
    _input.clear();
    _jumpToLatest();

    String? failure;
    final saved = await _chat.send(
      toUserId: widget.withUserId,
      body: body,
      onError: (reason) => failure = reason,
    );

    if (!mounted) return;
    setState(() {
      final index = _messages.indexWhere((m) => m.id == optimistic.id);
      if (index != -1) {
        // Replaced by the stored message, or marked failed — never left
        // looking sent when it was not.
        _messages[index] = saved ?? optimistic.copyWith(pending: false, failed: true);
      }
      _sending = false;
    });

    if (failure != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure!), backgroundColor: const Color(0xFFDC2626)),
      );
    }
  }

  @override
  void dispose() {
    _incoming?.cancel();
    _read?.cancel();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.withName,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800)),
            ValueListenableBuilder<bool>(
              valueListenable: _chat.isConnected,
              builder: (context, connected, _) => Text(
                // Said plainly: a chat that has quietly lost its connection
                // still accepts typing, and the message would not arrive.
                connected ? 'Connected' : 'Reconnecting…',
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color: connected ? widget.accent : const Color(0xFF9CA3AF),
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.sp),
          onPressed: Get.back,
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(
            'No messages yet. Say hello.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 8.h),
      itemCount: _messages.length,
      itemBuilder: (context, index) => _buildBubble(_messages[index]),
    );
  }

  Widget _buildBubble(ChatMessage message) {
    final mine = _isMine(message);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        margin: EdgeInsets.symmetric(vertical: 3.h),
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: message.failed
              ? const Color(0xFFFEF2F2)
              : mine
                  ? widget.accent
                  : Colors.white,
          borderRadius: BorderRadius.circular(14.r).copyWith(
            bottomRight: mine ? Radius.circular(3.r) : Radius.circular(14.r),
            bottomLeft: mine ? Radius.circular(14.r) : Radius.circular(3.r),
          ),
          border: mine ? null : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.body,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.35,
                color: message.failed
                    ? const Color(0xFF991B1B)
                    : mine
                        ? Colors.white
                        : const Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _time(message.createdAt),
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: mine && !message.failed
                        ? Colors.white70
                        : const Color(0xFF9CA3AF),
                  ),
                ),
                if (mine) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    message.failed
                        ? Icons.error_outline
                        : message.pending
                            ? Icons.schedule
                            : message.readAt != null
                                ? Icons.done_all
                                : Icons.done,
                    size: 11.sp,
                    color: message.failed
                        ? const Color(0xFF991B1B)
                        : Colors.white70,
                  ),
                ],
              ],
            ),
            if (message.failed)
              Text('Not sent',
                  style: TextStyle(fontSize: 9.sp, color: const Color(0xFF991B1B))),
          ],
        ),
      ),
    );
  }

  String _time(DateTime at) {
    final local = at.toLocal();
    final h = local.hour.toString().padLeft(2, '0');
    final m = local.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildComposer() {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(fontSize: 13.sp),
                decoration: InputDecoration(
                  hintText: 'Write a message…',
                  hintStyle: TextStyle(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: const Color(0xFFF3F4F6),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22.r),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: _sending ? null : _send,
              child: Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: _sending ? const Color(0xFFE5E7EB) : widget.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send_rounded, size: 19.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

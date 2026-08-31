import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../chat_service.dart';
import 'chat_conversation_view.dart';

/// Every conversation this account is part of.
///
/// Shared by both apps: a customer sees the stores they have messaged, a
/// merchant sees the customers who messaged them, and the screen is the same.
class ChatListView extends StatefulWidget {
  final Color accent;
  final String title;

  const ChatListView({
    super.key,
    this.accent = const Color(0xFF1B7A43),
    this.title = 'Messages',
  });

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  final ChatService _chat = ChatService();
  List<ChatConversation> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _chat.connect();
    final items = await _chat.conversations();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.title,
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: widget.accent,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, indent: 70.w, color: const Color(0xFFF3F4F6)),
                    itemBuilder: (context, index) => _buildRow(_items[index]),
                  ),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 0.25.sh),
        Icon(Icons.forum_outlined, size: 44.sp, color: const Color(0xFFD1D5DB)),
        SizedBox(height: 12.h),
        Center(
          child: Text('No messages yet',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 48.w),
          child: Text(
            'Conversations appear here once you or somebody else starts one.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11.5.sp, height: 1.4, color: const Color(0xFF9CA3AF)),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(ChatConversation conversation) {
    final unread = conversation.unread > 0;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: CircleAvatar(
        radius: 22.r,
        backgroundColor: widget.accent.withValues(alpha: 0.12),
        child: Text(
          conversation.withName.isEmpty
              ? '?'
              : conversation.withName[0].toUpperCase(),
          style: TextStyle(
              fontSize: 15.sp, fontWeight: FontWeight.w800, color: widget.accent),
        ),
      ),
      title: Text(
        conversation.withName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 13.5.sp,
          fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: Text(
          // Marked so a merchant scanning the list can tell what is waiting
          // on them from what they already answered.
          '${conversation.lastFromMe ? 'You: ' : ''}${conversation.lastMessage}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5.sp,
            color: unread ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
            fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _when(conversation.lastAt),
            style: TextStyle(fontSize: 9.5.sp, color: const Color(0xFF9CA3AF)),
          ),
          if (unread) ...[
            SizedBox(height: 5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: widget.accent,
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: Text('${conversation.unread}',
                  style: TextStyle(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
            ),
          ],
        ],
      ),
      onTap: () async {
        await Get.to(() => ChatConversationView(
              withUserId: conversation.withUserId,
              withName: conversation.withName,
              accent: widget.accent,
            ));
        // The unread count is stale after reading a conversation.
        _load();
      },
    );
  }

  String _when(DateTime? at) {
    if (at == null) return '';
    final local = at.toLocal();
    final now = DateTime.now();
    final sameDay = local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    if (sameDay) {
      return '${local.hour.toString().padLeft(2, '0')}:'
          '${local.minute.toString().padLeft(2, '0')}';
    }
    return '${local.day}/${local.month}';
  }
}

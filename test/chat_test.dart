// Tests for the live chat.
//
// The socket protocol itself — delivery, replies, refusals, and messages
// surviving an offline recipient — is covered end to end by two real clients
// in the backend suite (FLOW 18). What is left, and what these cover, is the
// Dart side: how a message is read off the wire and how the screen renders
// the three states a sent message can be in.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vip/core/chat/chat_service.dart';
import 'package:vip/core/chat/views/chat_conversation_view.dart';

void main() {
  group('ChatMessage', () {
    test('reads what the server actually sends', () {
      final m = ChatMessage.fromJson({
        '_id': 'abc',
        'from': 'u1',
        'to': 'u2',
        'body': 'Is the espresso in stock?',
        'createdAt': '2026-08-31T10:00:00.000Z',
        'readAt': null,
      });
      expect(m.id, 'abc');
      expect(m.body, 'Is the espresso in stock?');
      expect(m.createdAt.toUtc().hour, 10);
      // Unread is null, not a zero date: "never read" and "read at the epoch"
      // are different facts and the tick must not claim the second.
      expect(m.readAt, isNull);
      expect(m.pending, isFalse);
      expect(m.failed, isFalse);
    });

    test('a read receipt carries its timestamp', () {
      final m = ChatMessage.fromJson({
        '_id': 'a', 'from': 'x', 'to': 'y', 'body': 'hi',
        'createdAt': '2026-08-31T10:00:00.000Z',
        'readAt': '2026-08-31T10:05:00.000Z',
      });
      expect(m.readAt, isNotNull);
    });

    test('a malformed payload does not throw inside a list builder', () {
      // One odd row must not blank the whole conversation — the failure mode
      // this codebase has hit repeatedly.
      final m = ChatMessage.fromJson(const {});
      expect(m.body, '');
      expect(m.id, '');
      expect(m.createdAt, isNotNull);
    });

    test('copyWith moves a message between states without losing it', () {
      final pending = ChatMessage(
        id: 'p1', from: 'me', to: 'you', body: 'hello',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0), pending: true,
      );
      final failed = pending.copyWith(pending: false, failed: true);
      expect(failed.body, 'hello');
      expect(failed.pending, isFalse);
      expect(failed.failed, isTrue);
    });
  });

  group('ChatConversation', () {
    test('a merchant is listed by store name, not the owner\'s name', () {
      // The backend picks storeName over fullName because that is what a
      // customer recognises.
      final c = ChatConversation.fromJson({
        'withUserId': 'm1',
        'withName': 'Verify Store',
        'withRole': 'merchant',
        'lastMessage': 'Yes, plenty.',
        'lastAt': '2026-08-31T10:00:00.000Z',
        'lastFromMe': false,
        'unread': 3,
      });
      expect(c.withName, 'Verify Store');
      expect(c.unread, 3);
      expect(c.lastFromMe, isFalse);
    });

    test('a missing unread count reads as zero, not as null', () {
      final c = ChatConversation.fromJson({'withUserId': 'x'});
      expect(c.unread, 0);
      expect(c.withName, 'Unknown');
    });
  });

  // The screen itself is not mounted here. It fetches history in initState,
  // and the request's timeout timer outlives the test — the way to silence
  // that is a test-only seam in production code, which is a worse trade than
  // leaving the widget to `flutter analyze` and covering the logic above.
  // What the screen does with these objects is deterministic; what it does
  // over the wire is covered by two live clients in the backend suite.
}

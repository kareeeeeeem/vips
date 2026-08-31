// Tests for the customer's order tracking.
//
// The backend behaviour — history written at every status change, privacy,
// coordinate validation, and the customer and the console agreeing on the
// same status — is covered in the backend suite (FLOW 19). These cover the
// Dart side: how the screen decides what to draw from what it was given.

import 'package:flutter_test/flutter_test.dart';
import 'package:vip/appuser/modules/orders/controllers/order_tracking_controller.dart';

void main() {
  late OrderTrackingController c;

  setUp(() => c = OrderTrackingController('order-1'));

  group('Labels', () {
    test('every status the platform can hold has a customer-facing name', () {
      // The enum has eleven values including two spellings of cancelled.
      // A status with no label would show the raw database string.
      for (final status in [
        'pending', 'confirmed', 'processing', 'ready', 'handover',
        'picked_up', 'delivered', 'canceled', 'cancelled',
        'refund_requested', 'refunded',
      ]) {
        final label = OrderTrackingController.label(status);
        expect(label, isNotEmpty);
        expect(label, isNot(equals(status)),
            reason: '$status falls through to the raw value');
      }
    });

    test('both spellings of cancelled read the same', () {
      expect(OrderTrackingController.label('canceled'),
          OrderTrackingController.label('cancelled'));
    });
  });

  group('What the screen draws', () {
    test('an order with no recorded history says so', () {
      // An empty timeline would read as nothing having happened to the
      // order, which is a different and worse claim than "not recorded".
      c.data.value = {'status': 'delivered', 'historyRecorded': false, 'history': []};
      expect(c.historyRecorded, isFalse);
    });

    test('a cancelled order leaves the step list behind', () {
      // The stages are meaningless once an order stops, so the screen shows
      // what happened instead of what was supposed to.
      for (final stopped in ['cancelled', 'canceled', 'refunded', 'refund_requested']) {
        c.data.value = {'status': stopped};
        expect(c.isStopped, isTrue, reason: stopped);
      }
      for (final running in ['pending', 'processing', 'handover', 'delivered']) {
        c.data.value = {'status': running};
        expect(c.isStopped, isFalse, reason: running);
      }
    });

    test('a stage only carries a time when one was recorded', () {
      c.data.value = {
        'status': 'processing',
        'historyRecorded': true,
        'history': [
          {'status': 'pending', 'at': '2026-09-01T09:00:00.000Z', 'note': '', 'by': ''},
          {'status': 'processing', 'at': '2026-09-01T09:10:00.000Z',
            'note': 'Started preparing', 'by': 'merchant'},
        ],
      };
      expect(c.entryFor('pending'), isNotNull);
      expect(c.entryFor('processing')!['note'], 'Started preparing');
      // Nothing invented for a stage that has not happened.
      expect(c.entryFor('delivered'), isNull);
      expect(c.entryFor('handover'), isNull);
    });

    test('live location is null until something reports one', () {
      c.data.value = {'status': 'handover', 'liveLocation': null};
      expect(c.liveLocation, isNull);
      c.data.value = {
        'status': 'handover',
        'liveLocation': {'lat': 36.8065, 'lng': 10.1815},
      };
      expect(c.liveLocation!['lat'], 36.8065);
    });

    test('an absent estimate is null, not a date at the epoch', () {
      c.data.value = {'status': 'processing'};
      expect(c.estimatedDeliveryAt, isNull);
      c.data.value = {'estimatedDeliveryAt': '2026-09-01T12:00:00.000Z'};
      expect(c.estimatedDeliveryAt, isNotNull);
    });

    test('a malformed payload does not throw mid-build', () {
      c.data.value = {'history': 'not a list', 'liveLocation': 'nonsense'};
      expect(c.history, isEmpty);
      expect(c.liveLocation, isNull);
      expect(c.status, 'pending');
    });
  });

  group('The stage flow', () {
    test('runs from placed to delivered without gaps', () {
      expect(OrderTrackingController.flow.first, 'pending');
      expect(OrderTrackingController.flow.last, 'delivered');
      // Every stage drawn must be one the backend can actually set, or the
      // screen would show a step an order can never reach.
      const backendEnum = {
        'pending', 'confirmed', 'processing', 'ready', 'handover',
        'picked_up', 'delivered', 'canceled', 'cancelled',
        'refund_requested', 'refunded',
      };
      for (final stage in OrderTrackingController.flow) {
        expect(backendEnum, contains(stage));
      }
    });
  });
}

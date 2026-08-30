import 'dart:developer' as developer;

import 'package:device_calendar/device_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

/// Best-effort mirroring of payments into the device calendar.
///
/// Note: `READ_CALENDAR`/`WRITE_CALENDAR` are not declared in the Android
/// manifest and `NSCalendars*` keys are absent from Info.plist, so this
/// currently no-ops on both platforms. v1.0 hid that behind an empty `catch`;
/// the failure is now logged so the cause is visible when the permissions are
/// added.
abstract final class CalendarSync {
  static Future<void> logPayment({
    required String participantName,
    required String planTitle,
    required double amount,
    required double totalPaid,
  }) async {
    try {
      final plugin = DeviceCalendarPlugin();
      var granted = await plugin.hasPermissions();
      if (granted.isSuccess && !(granted.data ?? false)) {
        granted = await plugin.requestPermissions();
      }
      if (!granted.isSuccess || !(granted.data ?? false)) {
        developer.log('Calendar permission not granted; skipping',
            name: 'CalendarSync');
        return;
      }

      final calendars = (await plugin.retrieveCalendars()).data;
      final writable =
          calendars?.where((c) => c.isReadOnly == false).toList() ?? const [];
      if (writable.isEmpty) return;

      final start = tz.TZDateTime.now(tz.local);
      await plugin.createOrUpdateEvent(Event(
        writable.first.id,
        title: 'Kontri: $participantName paid '
            '${amount.toStringAsFixed(2)}',
        description: 'Contribution towards $planTitle. '
            'Total paid so far: ${totalPaid.toStringAsFixed(2)}.',
        start: start,
        end: start.add(const Duration(hours: 1)),
      ));
    } catch (error, stack) {
      developer.log('Calendar sync failed',
          name: 'CalendarSync', error: error, stackTrace: stack);
    }
  }
}

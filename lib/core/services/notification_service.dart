import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Callback function - notification bosilganda
  static Function(String)? onNotificationTap;

  Future<void> initialize() async {
    try {
      // Timezone initialization
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Tashkent'));

      // Android settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@drawable/ic_stat_notification');

      // iOS settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize with callback
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('📱 Notification tapped: ${response.payload}');
          if (response.payload != null) {
            // Callback chaqirish
            onNotificationTap?.call(response.payload!);
          }
        },
      );

      // Request permissions for Android 13+
      await _requestPermissions();

      print('✅ Notification service initialized');
    } catch (e) {
      print('❌ Notification initialization error: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? granted = await androidPlugin
          ?.requestNotificationsPermission();
      print(
        '📱 Notification permission: ${granted == true ? "Granted" : "Denied"}',
      );
    } catch (e) {
      print('❌ Permission request error: $e');
    }
  }

  // Har kuni soat 20:00 da notification schedule qilish
  Future<void> scheduleDailyAnalysis() async {
    try {
      await _notifications.zonedSchedule(
        0, // notification ID
        '📊 Kunlik xarajatlar tahlili',
        'Bugungi xarajatlaringizni ko\'ring va AI tavsiyalarini oling!',
        _nextInstanceOf20PM(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_analysis_channel',
            'Kunlik tahlil',
            channelDescription: 'Har kuni xarajatlar tahlili',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@drawable/ic_stat_notification',
            styleInformation: BigTextStyleInformation(
              'Bugungi xarajatlaringizni ko\'ring va AI tavsiyalarini oling!',
            ),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily_analysis',
      );

      print('✅ Daily notification scheduled for 20:00');
    } catch (e) {
      print('❌ Schedule notification error: $e');
    }
  }

  // Keyingi 20:00 ni hisoblash
  tz.TZDateTime _nextInstanceOf20PM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20, // 20:00
      0, // 0 minut
      0, // 0 sekund
    );

    // Agar hozir 20:00 dan keyin bo'lsa, ertangi kunga o'tkazish
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print('📅 Next notification: $scheduledDate');
    return scheduledDate;
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    print('🗑️ All notifications cancelled');
  }
}

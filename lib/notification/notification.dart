import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:todo_app/model/aTodo.dart';

class NotificationService {

  static final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();

    final DarwinInitializationSettings  initializationSettingsIOS =
    DarwinInitializationSettings (
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
    ); // <------

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future addNotification(aTodo todo) async {
    var scheduledDate = DateTime.parse("${todo.date} ${todo.time}").subtract(Duration(minutes: 10));
    var scheduledDateTz = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

    if (scheduledDate.isAfter(DateTime.now())){
      scheduledDateTz = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      todo.id,
      todo.title,
      'Cần thực hiện \"${todo.title}\" vào lúc ${todo.time} ngày ${todo.date}!',
      scheduledDateTz,
      const NotificationDetails(
          android: AndroidNotificationDetails(
            'whatever',
            'whatever',
            icon: "@mipmap/ic_launcher",
            playSound: true,
            importance: Importance.max,
            priority: Priority.high,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'notification',
            presentSound: true,
          ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future cancelNotification(aTodo todo) async {
    await flutterLocalNotificationsPlugin.cancel(todo.id);
  }
}
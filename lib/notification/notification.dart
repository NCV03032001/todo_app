import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:todo_app/model/aTodo.dart';

class NotificationService {

  static final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

    final DarwinInitializationSettings  initializationSettingsIOS =
    DarwinInitializationSettings (
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: null); // <------

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future addNotification(aTodo todo) async {
    var scheduledDate = DateTime.parse("${todo.date} ${todo.time}").subtract(Duration(minutes: 10));

    print(todo);
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
      todo.description,
      scheduledDateTz,
      const NotificationDetails(
          android: AndroidNotificationDetails(
            'whatever',
            'whatever',
            playSound: true,
            importance: Importance.max,
            priority: Priority.high,
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
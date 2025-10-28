import 'package:alarm_clock/models/alarm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class AlarmService extends ChangeNotifier {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'alarm_database.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE alarms (id INTEGER PRIMARY KEY AUTOINCREMENT, alarmDateTime INTEGER)',
    );
  }

  Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleAlarm(Alarm alarm) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        alarm.id!,
        'Alarm', //title
        'Your Alarm is ringing', //body
        tz.TZDateTime.from(alarm.alarmDateTime, tz.local),
        const NotificationDetails(
            android: AndroidNotificationDetails('channel_id', 'channel_name',
                channelDescription: 'channel_description')
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime);
  }

  Future<List<Alarm>> getAlarms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('alarms');
    return List.generate(maps.length, (i) {
      return Alarm.fromMap(maps[i]);
    });
  }

  Future<void> saveAlarm(Alarm alarm) async {
    final db = await database;
    alarm.id = await db.insert('alarms', alarm.toMap());
    scheduleAlarm(alarm);
    notifyListeners();
  }

  Future<void> deleteAlarm(int id) async {
    final db = await database;
    await db.delete(
      'alarms',
      where: 'id = ?',
      whereArgs: [id],
    );
    await flutterLocalNotificationsPlugin.cancel(id);
    notifyListeners();
  }
}

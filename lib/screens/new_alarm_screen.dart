import 'package:alarm_clock/models/alarm.dart';
import 'package:alarm_clock/services/alarm_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NewAlarmScreen extends StatefulWidget {
  @override
  _NewAlarmScreenState createState() => _NewAlarmScreenState();
}

class _NewAlarmScreenState extends State<NewAlarmScreen> {
  DateTime _selectedTime = DateTime.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Alarm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Time: ${DateFormat('hh:mm a').format(_selectedTime)}'),
              onTap: () => _selectTime(context),
            ),
            ElevatedButton(
              onPressed: () {
                final alarmService = Provider.of<AlarmService>(context, listen: false);
                final now = DateTime.now();
                DateTime scheduledTime = _selectedTime;

                if (scheduledTime.isBefore(now)) {
                  scheduledTime = scheduledTime.add(Duration(days: 1));
                }

                final alarm = Alarm(
                    alarmDateTime: scheduledTime
                );

                alarmService.saveAlarm(alarm);
                Navigator.pop(context);
              },
              child: Text('Save Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:alarm_clock/models/alarm.dart';
import 'package:alarm_clock/screens/new_alarm_screen.dart';
import 'package:alarm_clock/services/alarm_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AlarmListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alarmService = Provider.of<AlarmService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarms'),
      ),
      body: FutureBuilder<List<Alarm>>(
        future: alarmService.getAlarms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final alarms = snapshot.data ?? [];
            return ListView.builder(
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return Dismissible(
                  key: Key(alarm.id.toString()),
                  onDismissed: (direction) {
                    alarmService.deleteAlarm(alarm.id!); // Force unwrap is fine here.
                  },
                  child: ListTile(
                    title: Text(DateFormat('hh:mm a').format(alarm.alarmDateTime)),
                    subtitle: Text('Alarm ID: ${alarm.id}'),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewAlarmScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
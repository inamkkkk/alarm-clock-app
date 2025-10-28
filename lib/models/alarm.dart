class Alarm {
  int? id;
  DateTime alarmDateTime;

  Alarm({this.id, required this.alarmDateTime});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'alarmDateTime': alarmDateTime.millisecondsSinceEpoch,
    };
  }

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      alarmDateTime: DateTime.fromMillisecondsSinceEpoch(map['alarmDateTime']),
    );
  }
}
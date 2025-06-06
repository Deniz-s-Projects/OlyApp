part of 'models.dart';
class TransitStop {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  TransitStop({required this.id, required this.name});

  factory TransitStop.fromMap(Map<String, dynamic> map) => TransitStop(
        id: map['id'].toString(),
        name: map['name'] as String,
      );

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory TransitStop.fromJson(Map<String, dynamic> json) =>
      TransitStop.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

class TransitDeparture {
  final String line;
  final String destination;
  final DateTime time;

  TransitDeparture({
    required this.line,
    required this.destination,
    required this.time,
  });

  factory TransitDeparture.fromMap(Map<String, dynamic> map) => TransitDeparture(
        line: map['line'] as String,
        destination: map['destination'] as String,
        time: _parseDate(map['time']),
      );

  Map<String, dynamic> toMap() => {
        'line': line,
        'destination': destination,
        'time': time.toIso8601String(),
      };
}

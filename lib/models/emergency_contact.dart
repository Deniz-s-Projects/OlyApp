part of 'models.dart';

class EmergencyContact {
  final String? id;
  final String name;
  final String phone;
  final String? description;

  EmergencyContact({
    this.id,
    required this.name,
    required this.phone,
    this.description,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map) =>
      EmergencyContact(
        id: map['id']?.toString() ?? map['_id']?.toString(),
        name: map['name'] as String,
        phone: map['phone'] as String,
        description: map['description'] as String?,
      );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'phone': phone,
    'description': description,
  };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

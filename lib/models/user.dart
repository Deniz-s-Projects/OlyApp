part of 'models.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String email;
  @HiveField(3)
  // Path or URL to the user's avatar image
  final String? avatarUrl;
  @HiveField(4)
  final bool isAdmin;
  @HiveField(5)
  final bool isListed;
  @HiveField(6)
  final String? bio;
  @HiveField(7)
  final String? room;

  User({
    this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isAdmin = false,
    this.isListed = false,
    this.bio,
    this.room,
  });

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id']?.toString(),
    name: map['name'] as String,
    email: map['email'] as String,
    avatarUrl: map['avatarUrl'] as String?,
    isAdmin: (map['isAdmin'] ?? false) as bool,
    isListed: (map['isListed'] ?? false) as bool,
    bio: map['bio'] as String?,
    room: map['room'] as String?,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'isAdmin': isAdmin,
    'isListed': isListed,
    'bio': bio,
    'room': room,
  };

  factory User.fromJson(Map<String, dynamic> json) => User.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory User.fromJsonString(String source) =>
      User.fromMap(jsonDecode(source));
}

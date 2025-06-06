part of 'models.dart';
@HiveType(typeId: 4)
enum ItemCategory {
  @HiveField(0)
  furniture,
  @HiveField(1)
  books,
  @HiveField(2)
  electronics,
  @HiveField(3)
  other,
  @HiveField(4)
  appliances,
  @HiveField(5)
  clothing,
}

class ItemRating {
  final int rating;
  final String? review;

  ItemRating({required this.rating, this.review});

  factory ItemRating.fromMap(Map<String, dynamic> map) => ItemRating(
        rating: (map['rating'] as num).toInt(),
        review: map['review'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'rating': rating,
        if (review != null) 'review': review,
      };

  factory ItemRating.fromJson(Map<String, dynamic> json) =>
      ItemRating.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

@HiveType(typeId: 5)
class Item {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String ownerId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final String? imageUrl;
  @HiveField(5)
  final double? price;
  @HiveField(6)
  final bool isFree;
  @HiveField(7)
  final ItemCategory category;
  @HiveField(8)
  final DateTime createdAt;
  final bool completed;
  final List<ItemRating> ratings;

  Item({
    this.id,
    required this.ownerId,
    required this.title,
    this.description,
    this.imageUrl,
    this.price,
    this.isFree = false,
    this.category = ItemCategory.other,
    DateTime? createdAt,
    this.completed = false,
    this.ratings = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  factory Item.fromMap(Map<String, dynamic> map) => Item(
    id: map['id'] as int?,
    ownerId: map['ownerId'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    imageUrl: map['imageUrl'] as String?,
    price: map['price'] != null ? (map['price'] as num).toDouble() : null,
    isFree:
        map['isFree'] is bool
            ? map['isFree'] as bool
            : (map['isFree'] as int) == 1,
    category:
        map['category'] is int
            ? ItemCategory.values[map['category'] as int]
            : ItemCategory.values.firstWhere(
              (e) => e.name == map['category'] as String,
            ),
    createdAt: _parseDate(map['createdAt']),
    completed: map['completed'] as bool? ?? false,
    ratings: (map['ratings'] as List<dynamic>? ?? const [])
        .map((e) => ItemRating.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'ownerId': ownerId,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'price': price,
    'isFree': isFree,
    'category': category.name,
    'createdAt': createdAt.toIso8601String(),
    'completed': completed,
    'ratings': ratings.map((e) => e.toMap()).toList(),
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
  String toJsonString() => jsonEncode(toJson());
  factory Item.fromJsonString(String source) =>
      Item.fromMap(jsonDecode(source));

  double get averageRating {
    if (ratings.isEmpty) return 0;
    final total = ratings.fold<int>(0, (sum, r) => sum + r.rating);
    return total / ratings.length;
  }
}

part of 'models.dart';

class ServiceRating {
  final int rating;
  final String? review;

  ServiceRating({required this.rating, this.review});

  factory ServiceRating.fromMap(Map<String, dynamic> map) => ServiceRating(
        rating: (map['rating'] as num).toInt(),
        review: map['review'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'rating': rating,
        if (review != null) 'review': review,
      };

  factory ServiceRating.fromJson(Map<String, dynamic> json) =>
      ServiceRating.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

class ServiceListing {
  final int? id;
  final String userId;
  final String title;
  final String description;
  final String? contact;
  final DateTime createdAt;
  final List<ServiceRating> ratings;

  ServiceListing({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.contact,
    DateTime? createdAt,
    this.ratings = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  factory ServiceListing.fromMap(Map<String, dynamic> map) => ServiceListing(
        id: map['id'] as int?,
        userId: map['userId'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        contact: map['contact'] as String?,
        createdAt: _parseDate(map['createdAt']),
        ratings: (map['ratings'] as List<dynamic>? ?? const [])
            .map((e) => ServiceRating.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'contact': contact,
        'createdAt': createdAt.toIso8601String(),
        'ratings': ratings.map((e) => e.toMap()).toList(),
      };

  factory ServiceListing.fromJson(Map<String, dynamic> json) =>
      ServiceListing.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  double get averageRating {
    if (ratings.isEmpty) return 0;
    final total = ratings.fold<int>(0, (sum, r) => sum + r.rating);
    return total / ratings.length;
  }
}

part of 'models.dart';
class Poll {
  final String? id;
  final String question;
  final List<String> options;
  final List<int> counts;

  Poll({
    this.id,
    required this.question,
    required List<String> options,
    List<int>? counts,
  })  : options = List.unmodifiable(options),
        counts = counts != null
            ? List<int>.from(counts)
            : List<int>.filled(options.length, 0);

  factory Poll.fromMap(Map<String, dynamic> map) => Poll(
        id: map['_id']?.toString() ?? map['id']?.toString(),
        question: map['question'] as String,
        options:
            (map['options'] as List<dynamic>).map((e) => e.toString()).toList(),
        counts: (map['counts'] as List<dynamic>? ?? const [])
            .map((e) => (e as num).toInt())
            .toList(),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'question': question,
        'options': options,
        'counts': counts,
      };

  factory Poll.fromJson(Map<String, dynamic> json) => Poll.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

class PollVote {
  final String? id;
  final String pollId;
  final String userId;
  final int option;

  PollVote({
    this.id,
    required this.pollId,
    required this.userId,
    required this.option,
  });

  factory PollVote.fromMap(Map<String, dynamic> map) => PollVote(
        id: map['_id']?.toString() ?? map['id']?.toString(),
        pollId: map['pollId'].toString(),
        userId: map['userId'].toString(),
        option: map['option'] is int
            ? map['option'] as int
            : int.parse(map['option'].toString()),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'pollId': pollId,
        'userId': userId,
        'option': option,
      };

  factory PollVote.fromJson(Map<String, dynamic> json) => PollVote.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

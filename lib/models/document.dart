part of 'models.dart';

class Document {
  final String? id;
  final String uploaderId;
  final String fileName;
  final String url;

  Document({
    this.id,
    required this.uploaderId,
    required this.fileName,
    required this.url,
  });

  factory Document.fromMap(Map<String, dynamic> map) => Document(
        id: map['id']?.toString() ?? map['_id']?.toString(),
        uploaderId: map['uploaderId'] as String,
        fileName: map['fileName'] as String,
        url: map['url'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'uploaderId': uploaderId,
        'fileName': fileName,
        'url': url,
      };

  factory Document.fromJson(Map<String, dynamic> json) =>
      Document.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

part of 'models.dart';

class GalleryImage {
  final String? id;
  final String uploaderId;
  final String url;
  final String? caption;

  GalleryImage({
    this.id,
    required this.uploaderId,
    required this.url,
    this.caption,
  });

  factory GalleryImage.fromMap(Map<String, dynamic> map) => GalleryImage(
    id: map['id']?.toString() ?? map['_id']?.toString(),
    uploaderId: map['uploaderId'] as String,
    url: map['url'] as String,
    caption: map['caption'] as String?,
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'uploaderId': uploaderId,
    'url': url,
    'caption': caption,
  };

  factory GalleryImage.fromJson(Map<String, dynamic> json) =>
      GalleryImage.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}

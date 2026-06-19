class Report {
  final int id;
  final String title;
  final String description;
  final String likes;
  final String authorName;
  final String departmentName;
  final String categoriesName;
  final String latestStatus;
  final String? thumbnail;
  final DateTime createdAt;
  final double? locationLat;
  final double? locationLong;
  final String? location;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.likes,
    required this.authorName,
    required this.departmentName,
    required this.categoriesName,
    required this.latestStatus,
    this.thumbnail,
    required this.createdAt,
    this.locationLat,
    this.locationLong,
    this.location,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      likes: json['likes'] ?? '0',
      authorName: json['authorName'] ?? '',
      departmentName: json['departmentName'] ?? '',
      categoriesName: json['categoriesName'] ?? '',
      latestStatus: json['latestStatus'] ?? '',
      thumbnail: json['thumbnail'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      locationLat: (json['locationLat'] as num?)?.toDouble(),
      locationLong: (json['locationLong'] as num?)?.toDouble(),
      location: json['location'] as String?,
    );
  }

  Report copyWith({
    int? id,
    String? title,
    String? description,
    String? likes,
    String? authorName,
    String? departmentName,
    String? categoriesName,
    String? latestStatus,
    String? thumbnail,
    DateTime? createdAt,
    double? locationLat,
    double? locationLong,
    String? location,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      likes: likes ?? this.likes,
      authorName: authorName ?? this.authorName,
      departmentName: departmentName ?? this.departmentName,
      categoriesName: categoriesName ?? this.categoriesName,
      latestStatus: latestStatus ?? this.latestStatus,
      thumbnail: thumbnail ?? this.thumbnail,
      createdAt: createdAt ?? this.createdAt,
      locationLat: locationLat ?? this.locationLat,
      locationLong: locationLong ?? this.locationLong,
      location: location ?? this.location,
    );
  }
}

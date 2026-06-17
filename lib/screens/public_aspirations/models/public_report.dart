class PublicReport {
  final int id;
  final String title;
  final String description;
  final String location;
  final String likes;
  final String authorName;
  final String departmentName;
  final String categoriesName;
  final String? latestStatus;
  final String? thumbnail;
  final String? createdAt;
  final bool isLiked;

  PublicReport({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.likes,
    required this.authorName,
    required this.departmentName,
    required this.categoriesName,
    this.latestStatus,
    this.thumbnail,
    this.createdAt,
    this.isLiked = false,
  });

  factory PublicReport.fromJson(Map<String, dynamic> json) {
    return PublicReport(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      likes: json['likes']?.toString() ?? '0',
      authorName: json['authorName'] ?? '',
      departmentName: json['departmentName'] ?? '',
      categoriesName: json['categoriesName'] ?? '',
      latestStatus: json['latestStatus'],
      thumbnail: json['thumbnail'],
      createdAt: json['createdAt'],
      isLiked: json['isLiked'] ?? json['is_liked'] ?? false,
    );
  }
}

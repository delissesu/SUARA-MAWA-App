class Report {
  final int id;
  final String title;
  final String description;
  final int likes;
  final String authorName;
  final String departmentName;
  final String categoriesName;
  final String latestStatus;
  final String? thumbnail;
  final DateTime createdAt;

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
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      likes: json['likes'] ?? 0,
      authorName: json['authorName'] ?? '',
      departmentName: json['departmentName'] ?? '',
      categoriesName: json['categoriesName'] ?? '',
      latestStatus: json['latestStatus'] ?? '',
      thumbnail: json['thumbnail'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

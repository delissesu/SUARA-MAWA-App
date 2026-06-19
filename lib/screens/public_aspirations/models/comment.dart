class CommentUser {
  final String id;
  final String name;
  final int? photoProfileId;
  final String? urlFotoProfil;

  CommentUser({
    required this.id,
    required this.name,
    this.photoProfileId,
    this.urlFotoProfil,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photoProfileId: json['photoProfileId'],
      urlFotoProfil: json['url_foto_profil'],
    );
  }
}

class Comment {
  final int id;
  final int reportId;
  final String userId;
  final String comment;
  final String createdAt;
  final CommentUser? user;

  Comment({
    required this.id,
    required this.reportId,
    required this.userId,
    required this.comment,
    required this.createdAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      reportId: json['reportId'],
      userId: json['userId'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] ?? '',
      user: json['user'] != null ? CommentUser.fromJson(json['user']) : null,
    );
  }
}

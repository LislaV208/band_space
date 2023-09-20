// ignore_for_file: non_constant_identifier_names

class Comment {
  final String id;
  final DateTime? created_at;
  final String created_by;
  final String content;

  const Comment({
    required this.id,
    this.created_at,
    required this.created_by,
    required this.content,
  });
}

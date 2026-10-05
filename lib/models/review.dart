class Review {
  final String id;
  final String authorName;
  final double rating;
  final String comment;
  final DateTime date;
  final String? avatarUrl;

  const Review({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.date,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorName': authorName,
    'rating': rating,
    'comment': comment,
    'date': date.toIso8601String(),
    'avatarUrl': avatarUrl,
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'] as String,
    authorName: json['authorName'] as String,
    rating: (json['rating'] as num).toDouble(),
    comment: json['comment'] as String,
    date: DateTime.parse(json['date'] as String),
    avatarUrl: json['avatarUrl'] as String?,
  );
}

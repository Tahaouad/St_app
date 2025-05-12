class ContentItem {
  final int id;
  final String title;
  final String description;
  final String posterUrl;
  final double rating;
  final int releaseYear;
  final String maturityRating;
  final bool isFeatured;

  ContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.rating,
    this.releaseYear = 0,
    this.maturityRating = '',
    this.isFeatured = false,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      posterUrl: json['posterUrl'] ?? '',
      rating: (json['ratingAVG'] ?? 0.0).toDouble(),
      releaseYear: json['releaseYear'] ?? 0,
      maturityRating: json['maturityRating'] ?? '',
      isFeatured: json['isFeatured'] ?? false,
    );
  }
}

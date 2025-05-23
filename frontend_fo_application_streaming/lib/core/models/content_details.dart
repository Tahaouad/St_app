enum ContentType {
  movie,
  series,
}

extension ContentTypeExtension on ContentType {
  String get name {
    switch (this) {
      case ContentType.movie:
        return 'Film';
      case ContentType.series:
        return 'Série';
    }
  }

  String get apiValue {
    switch (this) {
      case ContentType.movie:
        return 'movie';
      case ContentType.series:
        return 'tv';
    }
  }
}

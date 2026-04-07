library;
///
/// Contains the three Decodable structs:
///   - [MovieList]    (top-level API response)
///   - [Dates]        (date range in API response)
///   - [MovieResult]  (individual movie item — renamed from ResultModel)

// ---------------------------------------------------------------------------
// MovieList  (mirrors struct MovieList)
// ---------------------------------------------------------------------------
class MovieList {
  final Dates? dates;
  int? page;
  List<MovieResult>? results;
  final int? totalPages;
  final int? totalResults;

  MovieList({
    this.dates,
    this.page,
    this.results,
    this.totalPages,
    this.totalResults,
  });

  factory MovieList.fromJson(Map<String, dynamic> json) => MovieList(
        dates: json['dates'] != null ? Dates.fromJson(json['dates'] as Map<String, dynamic>) : null,
        page: json['page'] as int?,
        results: (json['results'] as List<dynamic>?)
            ?.map((e) => MovieResult.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalPages: json['total_pages'] as int?,
        totalResults: json['total_results'] as int?,
      );
}

// ---------------------------------------------------------------------------
// Dates  (mirrors struct Dates)
// ---------------------------------------------------------------------------
class Dates {
  final String maximum;
  final String minimum;

  const Dates({required this.maximum, required this.minimum});

  factory Dates.fromJson(Map<String, dynamic> json) => Dates(
        maximum: json['maximum'] as String,
        minimum: json['minimum'] as String,
      );
}

// ---------------------------------------------------------------------------
// MovieResult  (mirrors struct ResultModel)
// ---------------------------------------------------------------------------
class MovieResult {
  final bool? adult;
  final String? backdropPath;
  final List<int>? genreIds;
  final int? id;
  final String? originalLanguage;
  final String? originalTitle;
  final String? overview;
  final double? popularity;
  final String? posterPath;
  final String? releaseDate;
  final String? title;
  final bool? video;
  final double? voteAverage;
  final int? voteCount;

  const MovieResult({
    this.adult,
    this.backdropPath,
    this.genreIds,
    this.id,
    this.originalLanguage,
    this.originalTitle,
    this.overview,
    this.popularity,
    this.posterPath,
    this.releaseDate,
    this.title,
    this.video,
    this.voteAverage,
    this.voteCount,
  });

  factory MovieResult.fromJson(Map<String, dynamic> json) => MovieResult(
        adult: json['adult'] as bool?,
        backdropPath: json['backdrop_path'] as String?,
        genreIds: (json['genre_ids'] as List<dynamic>?)?.cast<int>(),
        id: json['id'] as int?,
        originalLanguage: json['original_language'] as String?,
        originalTitle: json['original_title'] as String?,
        overview: json['overview'] as String?,
        popularity: (json['popularity'] as num?)?.toDouble(),
        posterPath: json['poster_path'] as String?,
        releaseDate: json['release_date'] as String?,
        title: json['title'] as String?,
        video: json['video'] as bool?,
        voteAverage: (json['vote_average'] as num?)?.toDouble(),
        voteCount: json['vote_count'] as int?,
      );

  /// Mirrors `var movieRating: Int` computed property in Swift.
  /// Maps voteAverage (0-10) to a 1-4 star rating.
  int get movieRating {
    final avg = voteAverage ?? 0.0;
    if (avg < 2) return 1;
    if (avg < 4) return 2;
    if (avg < 6) return 3;
    return 4;
  }
}

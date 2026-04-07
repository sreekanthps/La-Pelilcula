/// Mirrors [MovieDetailsModel.swift] — Full movie detail API response models.
///
/// Contains:
///   - [MovieDetailsModel]   — top-level detail response + computed properties
///   - [MovieDetails]        — presentation-ready display struct (from MovieDetailsView.swift)
///   - [Genre]               — embedded genre
///   - [ProductionCompany]   — embedded production company
///   - [ProductionCountry]   — embedded production country
///   - [SpokenLanguage]      — embedded spoken language
///   - [BelongsToCollection] — optional collection membership
library;

// ---------------------------------------------------------------------------
// MovieDetails  (mirrors `struct MovieDetails` in MovieDetailsView.swift)
// A flattened, display-ready snapshot passed from ViewModel → View.
// ---------------------------------------------------------------------------
class MovieDetails {
  final String? title;
  final String? synopsis;
  final String? genre;
  final String? releaseDate;
  final String? runtime;
  final int? star;

  const MovieDetails({
    this.title,
    this.synopsis,
    this.genre,
    this.releaseDate,
    this.runtime,
    this.star,
  });
}

// ---------------------------------------------------------------------------
// MovieDetailsModel  (mirrors `struct MovieDetailsModel: Decodable`)
// ---------------------------------------------------------------------------
class MovieDetailsModel {
  final bool adult;
  final String backdropPath;
  final BelongsToCollection? belongsToCollection;
  final int budget;
  final List<Genre> genres;
  final String homepage;
  final int id;
  final String imdbId;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String posterPath;
  final List<ProductionCompany> productionCompanies;
  final List<ProductionCountry> productionCountries;
  final String releaseDate;
  final int revenue;
  final int runtime;
  final List<SpokenLanguage> spokenLanguages;
  final String status;
  final String tagline;
  final String title;
  final bool video;
  final double voteAverage;
  final int voteCount;

  const MovieDetailsModel({
    required this.adult,
    required this.backdropPath,
    this.belongsToCollection,
    required this.budget,
    required this.genres,
    required this.homepage,
    required this.id,
    required this.imdbId,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.productionCompanies,
    required this.productionCountries,
    required this.releaseDate,
    required this.revenue,
    required this.runtime,
    required this.spokenLanguages,
    required this.status,
    required this.tagline,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
  });

  factory MovieDetailsModel.fromJson(Map<String, dynamic> json) =>
      MovieDetailsModel(
        adult: json['adult'] as bool? ?? false,
        backdropPath: json['backdrop_path'] as String? ?? '',
        belongsToCollection: json['belongs_to_collection'] != null
            ? BelongsToCollection.fromJson(
                json['belongs_to_collection'] as Map<String, dynamic>)
            : null,
        budget: json['budget'] as int? ?? 0,
        genres: (json['genres'] as List<dynamic>? ?? [])
            .map((e) => Genre.fromJson(e as Map<String, dynamic>))
            .toList(),
        homepage: json['homepage'] as String? ?? '',
        id: json['id'] as int? ?? 0,
        imdbId: json['imdb_id'] as String? ?? '',
        originalLanguage: json['original_language'] as String? ?? '',
        originalTitle: json['original_title'] as String? ?? '',
        overview: json['overview'] as String? ?? '',
        popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
        posterPath: json['poster_path'] as String? ?? '',
        productionCompanies: (json['production_companies'] as List<dynamic>? ?? [])
            .map((e) => ProductionCompany.fromJson(e as Map<String, dynamic>))
            .toList(),
        productionCountries: (json['production_countries'] as List<dynamic>? ?? [])
            .map((e) => ProductionCountry.fromJson(e as Map<String, dynamic>))
            .toList(),
        releaseDate: json['release_date'] as String? ?? '',
        revenue: json['revenue'] as int? ?? 0,
        runtime: json['runtime'] as int? ?? 0,
        spokenLanguages: (json['spoken_languages'] as List<dynamic>? ?? [])
            .map((e) => SpokenLanguage.fromJson(e as Map<String, dynamic>))
            .toList(),
        status: json['status'] as String? ?? '',
        tagline: json['tagline'] as String? ?? '',
        title: json['title'] as String? ?? '',
        video: json['video'] as bool? ?? false,
        voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
        voteCount: json['vote_count'] as int? ?? 0,
      );

  /// Mirrors `var movieRating: Int` — maps voteAverage (0-10) to 1-5 stars.
  int get movieRating {
    if (voteAverage < 2) return 1;
    if (voteAverage < 4) return 2;
    if (voteAverage < 6) return 3;
    if (voteAverage < 8) return 4;
    return 5;
  }

  /// Mirrors `var moviegenre: String` — comma-joined genre names.
  String get movieGenre => genres.map((g) => g.name).join(' , ');

  /// Mirrors `var movierunTime: String` — runtime as "Xm" or "Xh Ym".
  String get movieRunTime {
    if (runtime <= 0) return 'N/A';
    final h = runtime ~/ 60;
    final m = runtime % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Mirrors `displayStringDate` extension — formats "yyyy-MM-dd" → "MMM d, yyyy".
  String get displayReleaseDate {
    if (releaseDate.isEmpty) return '';
    try {
      final parts = releaseDate.split('-');
      if (parts.length != 3) return releaseDate;
      final months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec',
      ];
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final year = parts[0];
      return '${months[month - 1]} $day, $year';
    } catch (_) {
      return releaseDate;
    }
  }
}

// ---------------------------------------------------------------------------
// Genre
// ---------------------------------------------------------------------------
class Genre {
  final int id;
  final String name;
  const Genre({required this.id, required this.name});
  factory Genre.fromJson(Map<String, dynamic> json) =>
      Genre(id: json['id'] as int, name: json['name'] as String);
}

// ---------------------------------------------------------------------------
// ProductionCompany
// ---------------------------------------------------------------------------
class ProductionCompany {
  final int id;
  final String? logoPath;
  final String name;
  final String originCountry;
  const ProductionCompany({
    required this.id,
    this.logoPath,
    required this.name,
    required this.originCountry,
  });
  factory ProductionCompany.fromJson(Map<String, dynamic> json) =>
      ProductionCompany(
        id: json['id'] as int,
        logoPath: json['logo_path'] as String?,
        name: json['name'] as String,
        originCountry: json['origin_country'] as String,
      );
}

// ---------------------------------------------------------------------------
// ProductionCountry
// ---------------------------------------------------------------------------
class ProductionCountry {
  final String iso31661;
  final String name;
  const ProductionCountry({required this.iso31661, required this.name});
  factory ProductionCountry.fromJson(Map<String, dynamic> json) =>
      ProductionCountry(
        iso31661: json['iso_3166_1'] as String,
        name: json['name'] as String,
      );
}

// ---------------------------------------------------------------------------
// SpokenLanguage
// ---------------------------------------------------------------------------
class SpokenLanguage {
  final String englishName;
  final String iso6391;
  final String name;
  const SpokenLanguage({
    required this.englishName,
    required this.iso6391,
    required this.name,
  });
  factory SpokenLanguage.fromJson(Map<String, dynamic> json) => SpokenLanguage(
        englishName: json['english_name'] as String,
        iso6391: json['iso_639_1'] as String,
        name: json['name'] as String,
      );
}

// ---------------------------------------------------------------------------
// BelongsToCollection
// ---------------------------------------------------------------------------
class BelongsToCollection {
  final int id;
  final String name;
  final String posterPath;
  final String backdropPath;
  const BelongsToCollection({
    required this.id,
    required this.name,
    required this.posterPath,
    required this.backdropPath,
  });
  factory BelongsToCollection.fromJson(Map<String, dynamic> json) =>
      BelongsToCollection(
        id: json['id'] as int,
        name: json['name'] as String,
        posterPath: json['poster_path'] as String? ?? '',
        backdropPath: json['backdrop_path'] as String? ?? '',
      );
}

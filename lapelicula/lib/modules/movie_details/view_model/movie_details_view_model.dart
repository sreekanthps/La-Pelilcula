import '../model/movie_details_model.dart';

/// Mirrors [MovieDetailsViewModel.swift]
///
/// A pure data-preparation class (no ChangeNotifier needed here —
/// the data is passed in at construction time just like the Swift init).
///
/// Exposes:
///   - [posterPath]      — raw path for the full-screen poster image
///   - [imdbId]          — IMDB ID for external navigation
///   - [getMovieDetails] — flattened [MovieDetails] display object
class MovieDetailsViewModel {
  /// Mirrors `var details: MovieDetailsModel?`
  final MovieDetailsModel? details;

  /// Mirrors `init(withDetails details: MovieDetailsModel?)`
  const MovieDetailsViewModel({this.details});

  /// Mirrors `var posterPath: String?`
  String? get posterPath => details?.posterPath;

  /// Mirrors `var imdbId: String?`
  String? get imdbId => details?.imdbId;

  /// Mirrors `func getMovieDetails() -> MovieDetails?`
  ///
  /// Builds a flattened [MovieDetails] from the raw model,
  /// applying the same computed transforms as Swift:
  ///   - `displayStringDate`  → [MovieDetailsModel.displayReleaseDate]
  ///   - `moviegenre`         → [MovieDetailsModel.movieGenre]
  ///   - `movierunTime`       → [MovieDetailsModel.movieRunTime]
  ///   - `movieRating`        → [MovieDetailsModel.movieRating]
  MovieDetails? getMovieDetails() {
    if (details == null) return null;
    return MovieDetails(
      title: details!.title,
      synopsis: details!.overview,
      genre: details!.movieGenre,
      releaseDate: details!.displayReleaseDate,
      runtime: details!.movieRunTime,
      star: details!.movieRating,
    );
  }
}

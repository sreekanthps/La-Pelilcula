import 'package:flutter/foundation.dart';

import '../model/home_screen_model.dart';
import '../../../utilities/app_constants.dart';
import '../../../utilities/service/http_methods.dart';
import '../../../utilities/service/http_request.dart';
import '../../../utilities/service/http_url.dart';
import '../../../utilities/service/http_utility.dart';

/// Mirrors [HomeScreenViewModel.swift]
///
/// Uses [ChangeNotifier] instead of Swift completion-handler callbacks,
/// so the Flutter View layer can simply call [notifyListeners] and rebuild.
///
/// Key methods mirrored:
///   - [getUpcomingList]       — paginated movie fetch
///   - [getMovieDetails]       — single movie detail fetch
///   - [calculateNewIndexes]   — mirrors calculateIndexPathsToReload
///   - [numberofMovies]        — getter
///   - [getMovieAtIndex]       — safe indexed access
///   - [getMovieIdAtIndex]     — safe id access
///   - [nextPage]              — pagination guard
class HomeScreenViewModel extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final HttpUtility _networkUtil = HttpUtility.shared;

  MovieList? movieList;

  /// Tracks the previous count before a page append (mirrors `previousCount`).
  int _previousCount = 0;

  /// Tracks loading state so the View can show a spinner.
  bool isLoading = false;

  /// Tracks error message for the View to display.
  String? errorMessage;

  // ---------------------------------------------------------------------------
  // Upcoming Movie Request  (mirrors `getUpcomingList`)
  // ---------------------------------------------------------------------------

  Future<bool> getUpcomingList({int pageIndex = 1}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final requestUri = HttpUrl.withComponents(
      AppConstants.baseURL + AppConstants.upcoming,
      components: {
        'api_key': AppConstants.apiKey,
        'page': pageIndex.toString(),
      },
    ).queryParamUri;

    if (requestUri == null) {
      isLoading = false;
      errorMessage = 'Invalid URL';
      notifyListeners();
      return false;
    }

    final (error, response) = await _networkUtil.request<MovieList>(
      request: HttpRequest(url: requestUri, method: HttpMethods.GET),
      fromJson: MovieList.fromJson,
    );

    isLoading = false;

    if (error != null || response == null) {
      errorMessage = error?.reason ?? 'Unknown error';
      notifyListeners();
      return false;
    }

    // Mirrors Swift: append to existing list if one already exists
    if (movieList != null && response.results != null) {
      _previousCount = movieList!.results?.length ?? 0;
      movieList!.results?.addAll(response.results!);
      movieList!.page = response.page;
    } else {
      movieList = response;
      _previousCount = 0;
    }

    notifyListeners();
    return true;
  }

  // ---------------------------------------------------------------------------
  // Movie Details Request  (mirrors `getMovieDetails`)
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> getMovieDetails({required int movieId}) async {
    final requestUri = HttpUrl.withComponents(
      AppConstants.baseURL + AppConstants.details + movieId.toString(),
      components: {'api_key': AppConstants.apiKey},
    ).queryParamUri;

    if (requestUri == null) return null;

    final (_, response) = await _networkUtil.request<Map<String, dynamic>>(
      request: HttpRequest(url: requestUri, method: HttpMethods.GET),
      fromJson: (json) => json,
    );

    return response;
  }

  // ---------------------------------------------------------------------------
  // Computed accessors  (mirrors Swift computed properties)
  // ---------------------------------------------------------------------------

  /// Total number of loaded movies. Mirrors `var numberofMovies: Int?`
  int get numberofMovies => movieList?.results?.length ?? 0;

  /// Safe movie accessor. Mirrors `getMovieatIndex`.
  MovieResult? getMovieAtIndex(int index) {
    final results = movieList?.results;
    if (results == null || index >= results.length) return null;
    return results[index];
  }

  /// Safe movie ID accessor. Mirrors `getMovieIndex`.
  int? getMovieIdAtIndex(int index) => getMovieAtIndex(index)?.id;

  /// Next page number, or null when all pages are loaded.
  /// Mirrors `var nextPage: Int?`
  int? get nextPage {
    final page = movieList?.page;
    final total = movieList?.totalPages;
    if (page == null || total == null) return null;
    return page + 1 <= total ? page + 1 : null;
  }

  /// Returns index range of newly added items.
  /// Mirrors `calculateIndexPathsToReload`.
  List<int> calculateNewIndexes() {
    final count = movieList?.results?.length ?? 0;
    if (count == 0) return [];
    return List.generate(count - _previousCount, (i) => _previousCount + i);
  }
}

/// Mirrors [Constants.swift] — App-wide constants.
class AppConstants {
  AppConstants._();

  // MARK: - API
  static const String baseURL = 'http://api.themoviedb.org/3/';
  static const String shortImageURL = 'https://image.tmdb.org/t/p/w500';
  static const String imdbUrl = 'https://www.imdb.com/title/';
  static const String bookmyShow = 'https://www.cathaycineplexes.com.sg/';
  static const String apiKey = '328c283cd27bd1877d9080ccb1604c91';

  // MARK: - Request params
  static const String upcoming = 'movie/upcoming';
  static const String details = 'movie/';

  // MARK: - Animation
  static const String animationFile = 'splashanimation';
  static const String loadingAnimation = 'loading';

  // MARK: - Date formats
  static const String dateFormatter = 'yyyy-MM-dd';
  static const String stringFormatter = 'MMM d, yyyy';
}

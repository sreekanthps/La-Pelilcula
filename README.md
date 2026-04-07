# 🎬 LaPelicula — Flutter

A Flutter port of the original [LaPelicula iOS app](https://github.com/sreekanthps/LaPelicula), a movie discovery app powered by [The Movie Database (TMDb) API](https://www.themoviedb.org/). Browse upcoming movies, view rich detail pages, and launch trailers — all in a clean MVVM architecture mirroring the original Swift codebase.

---

## 📦 SDK & Tool Versions

| Tool / SDK               | Version         | Notes                              |
|--------------------------|-----------------|------------------------------------|
| **Flutter**              | 3.41.6          | Stable channel                     |
| **Dart**                 | 3.11.4          | SDK constraint: `^3.11.4`          |
| **DevTools**             | 2.54.2          | Flutter inspector & profiler       |
| **Android compileSdk**   | 35              | Via `flutter.compileSdkVersion`    |
| **Android targetSdk**    | 35              | Via `flutter.targetSdkVersion`     |
| **Android minSdk**       | 21              | Via `flutter.minSdkVersion`        |
| **Kotlin**               | Plugin via Gradle | `id("kotlin-android")`           |
| **Java Compatibility**   | 17              | `sourceCompatibility = VERSION_17` |
| **Gradle**               | 8.14            | `gradle-8.14-all.zip`              |
| **iOS Deployment Target**| 13.0            | `IPHONEOS_DEPLOYMENT_TARGET`       |
| **App Version**          | 1.0.0+1         | versionName / versionCode          |

---

## 🚀 How to Run

### Prerequisites
- Flutter 3.41.6 installed and on `$PATH`
- For Android: Android Studio with an emulator or a physical device connected via USB
- For iOS: Xcode 15+ with a simulator or physical device (macOS only)

### Install Dependencies

```bash
cd lapelicula
flutter pub get
```

---

### ▶️ Android

```bash
# Run on connected Android device / emulator (debug)
flutter run

# Target a specific device
flutter devices                        # list available devices
flutter run -d <device-id>

# Release build (APK)
flutter build apk --release

# Release build (App Bundle)
flutter build appbundle --release
```

---

### ▶️ iOS

```bash
# Run on connected iOS device / simulator (debug)
flutter run

# Target a specific simulator
flutter devices                        # list available simulators
flutter run -d <simulator-id>

# Open in Xcode (for provisioning / signing)
open ios/Runner.xcworkspace

# Release build (IPA)
flutter build ipa --release
```

> **Note:** Run `pod install` inside the `ios/` directory if you encounter CocoaPods issues after adding new packages.

---

## 🗂️ Module Tree Structure

```
lapelicula/
└── lib/
    ├── main.dart                          # App entry-point, MaterialApp + routing
    ├── splash_screen.dart                 # Lottie animated splash screen
    │
    ├── modules/
    │   ├── home_screen/                   # Upcoming movies list
    │   │   ├── model/
    │   │   │   └── home_screen_model.dart         # MovieList & MovieResult models
    │   │   ├── view/
    │   │   │   ├── home_screen.dart               # Paginated ListView UI
    │   │   │   └── movie_card.dart                # Reusable movie list card widget
    │   │   └── view_model/
    │   │       └── home_screen_view_model.dart     # ChangeNotifier ViewModel
    │   │
    │   └── movie_details/                 # Full movie detail page
    │       ├── model/
    │       │   └── movie_details_model.dart        # Detailed movie data model
    │       ├── view/
    │       │   ├── movie_details_screen.dart       # Detail page UI
    │       │   └── movie_details_image_view.dart   # Hero image widget
    │       └── view_model/
    │           └── movie_details_view_model.dart   # Detail page ViewModel
    │
    └── utilities/
        ├── app_constants.dart             # API keys, base URLs, format strings
        └── service/                       # HTTP networking layer
            ├── service.dart               # Barrel export for the service layer
            ├── http_methods.dart          # HttpMethods enum (GET, POST)
            ├── http_request.dart          # Request protocol + HttpRequest model
            ├── http_url.dart              # HttpUrl — base URL + query params builder
            ├── http_network_error.dart    # HttpNetworkError exception model
            └── http_utility.dart          # Singleton HTTP dispatcher (HttpUtility)
```

---

## 📚 Supporting Libraries

| Package              | Version   | Purpose                                                         |
|----------------------|-----------|-----------------------------------------------------------------|
| `flutter` (SDK)      | bundled   | Core framework                                                  |
| `cupertino_icons`    | ^1.0.8    | iOS-style icon set for Material + Cupertino widgets             |
| `lottie`             | ^3.1.2    | Renders Lottie JSON animations (splash screen & loading states) |
| `http`               | ^1.2.1    | Dart HTTP client used by `HttpUtility` for all API calls        |
| `provider`           | ^6.1.2    | `ChangeNotifier`-based state management for ViewModels          |
| `url_launcher`       | ^6.3.1    | Opens IMDB links and Cathay Cineplexes in an in-app browser     |
| `flutter_lints` *(dev)* | ^6.0.0 | Recommended lint rules for code quality                        |
| `flutter_test` *(dev)* | bundled | Flutter unit & widget testing framework                        |

---

## 🌐 HTTP Code Implementation

The networking layer (`lib/utilities/service/`) is a full Dart port of the original Swift `HttpUtility` class, keeping the same API design.

### Architecture Overview

```
HttpUrl            →  Builds URI with query parameters
HttpRequest        →  Wraps URL + HTTP method + optional body
HttpUtility.shared →  Singleton dispatcher; executes GET / POST
HttpNetworkError   →  Typed error model (status code, reason, URL)
HttpMethods        →  Enum: GET | POST
```

### Core Class: `HttpUtility`

Singleton instance: `HttpUtility.shared`

```dart
// GET request — fetch and decode into a typed model
final (error, movie) = await HttpUtility.shared.request<Movie>(
  request: HttpRequest(url: uri, method: HttpMethods.GET),
  fromJson: Movie.fromJson,
);

if (error != null) {
  print('Error: ${error.reason} (HTTP ${error.httpStatusCode})');
} else {
  print(movie);
}
```

### Building URLs with Query Parameters

```dart
final uri = HttpUrl.withComponents(
  AppConstants.baseURL + AppConstants.upcoming,
  components: {
    'api_key': AppConstants.apiKey,
    'page': '1',
  },
).queryParamUri;
// → http://api.themoviedb.org/3/movie/upcoming?api_key=...&page=1
```

### Return Type — Dart Records

All network calls return a `(HttpNetworkError?, T?)` record:

| Result          | `error` | `value` |
|-----------------|---------|---------|
| ✅ Success       | `null`  | decoded model |
| ❌ Network error | error   | `null`  |
| ❌ Decode error  | error   | `null`  |

### Reading Local JSON Assets

```dart
// Single JSON object
final movie = await HttpUtility.shared.readJsonResponse<Movie>(
  name: 'assets/data/movie.json',
  fromJson: Movie.fromJson,
);

// JSON array
final movies = await HttpUtility.shared.readJsonArrayResponse<Movie>(
  name: 'assets/data/movies.json',
  fromJson: Movie.fromJson,
);
```

### API Endpoints

| Constant              | Value                                  |
|-----------------------|----------------------------------------|
| `baseURL`             | `http://api.themoviedb.org/3/`         |
| `upcoming`            | `movie/upcoming`                       |
| `details`             | `movie/<id>`                           |
| `shortImageURL`       | `https://image.tmdb.org/t/p/w500`      |
| `imdbUrl`             | `https://www.imdb.com/title/`          |
| `bookmyShow`          | `https://www.cathaycineplexes.com.sg/` |

### HTTP Layer File Reference

| File                   | Responsibility                                                  |
|------------------------|-----------------------------------------------------------------|
| `http_utility.dart`    | Singleton dispatcher — `getData`, `postData`, `request<T>`      |
| `http_url.dart`        | URL + query param builder (`queryParamUri`)                     |
| `http_request.dart`    | `Request` abstract class + `HttpRequest` concrete struct        |
| `http_methods.dart`    | `HttpMethods` enum (`GET`, `POST`) with `.value` extension      |
| `http_network_error.dart` | `HttpNetworkError` — status code, reason, url, body          |
| `service.dart`         | Barrel export — import one file to access the entire layer      |

---

## 🍎 Original iOS Project

This Flutter app is a port of the original Swift / UIKit iOS project:

👉 **[https://github.com/sreekanthps/LaPelicula](https://github.com/sreekanthps/LaPelicula)**

The Flutter implementation mirrors the iOS MVVM architecture, class names, method signatures, and networking layer as closely as possible, making it straightforward to compare the two codebases side-by-side.

---

## 📄 License

This project is for learning and portfolio purposes. Movie data is provided by [The Movie Database (TMDb)](https://www.themoviedb.org/).

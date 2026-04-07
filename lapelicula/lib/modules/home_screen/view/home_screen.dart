import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/home_screen_view_model.dart';
import '../model/home_screen_model.dart';
import 'movie_card.dart';
import '../../movie_details/model/movie_details_model.dart';
import '../../movie_details/view/movie_details_screen.dart';
import '../../../utilities/app_constants.dart';
import '../../../utilities/service/http_methods.dart';
import '../../../utilities/service/http_request.dart';
import '../../../utilities/service/http_url.dart';
import '../../../utilities/service/http_utility.dart';

/// Mirrors [HomeScreenViewController + HomeScreenView]
///
/// Flutter collapses the ViewController + View pair into a single
/// [StatefulWidget] backed by [HomeScreenViewModel] (via Provider).
///
/// Behaviour mirrored:
///   - Fetch upcoming movies on first appearance   (viewDidAppear)
///   - Paginated loading when scrolling to end     (scrollendEndRecordUpdate)
///   - Pull-to-refresh                             (pullTorefreshAction)
///   - Tap a movie card to navigate to details     (onSelectRecord)
///   - Dark background matching iOS Colors.backGround
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeScreenViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = HomeScreenViewModel();

    // Mirrors viewDidAppear -> getUpdatedContent()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.getUpcomingList();
    });

    // Mirrors scrollendEndRecordUpdate — trigger pagination near bottom
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _fetchNextPage();
    }
  }

  /// Mirrors `fetchUpdatedRecords`
  Future<void> _fetchNextPage() async {
    final nextPage = _viewModel.nextPage;
    if (nextPage == null || _viewModel.isLoading) return;
    await _viewModel.getUpcomingList(pageIndex: nextPage);
  }

  /// Pull-to-refresh. Mirrors `pullTorefreshAction`
  Future<void> _onRefresh() async {
    _viewModel.movieList = null;
    await _viewModel.getUpcomingList();
  }

  /// Mirrors `navigateToMoviedetails` — fetch full details then navigate
  void _onMovieTapped(MovieResult movie) async {
    final movieId = movie.id;
    if (movieId == null) return;

    // Show a brief loading indicator while fetching details
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFE5B33A)),
      ),
    );

    final requestUri = HttpUrl.withComponents(
      AppConstants.baseURL + AppConstants.details + movieId.toString(),
      components: {'api_key': AppConstants.apiKey},
    ).queryParamUri;

    MovieDetailsModel? details;
    if (requestUri != null) {
      final (_, response) = await HttpUtility.shared.request<MovieDetailsModel>(
        request: HttpRequest(url: requestUri, method: HttpMethods.GET),
        fromJson: MovieDetailsModel.fromJson,
      );
      details = response;
    }

    if (!mounted) return;
    Navigator.of(context).pop(); // dismiss loading dialog

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MovieDetailsScreen(movieDetailsModel: details),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeScreenViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        body: SafeArea(
          child: Consumer<HomeScreenViewModel>(
            builder: (context, vm, _) {
              // ---- Error state ----
              if (vm.errorMessage != null && vm.numberofMovies == 0) {
                return _ErrorView(
                  message: vm.errorMessage!,
                  onRetry: () => vm.getUpcomingList(),
                );
              }

              // ---- Empty + initial load ----
              if (vm.isLoading && vm.numberofMovies == 0) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE5B33A)),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- Header ----
                  const _HomeHeader(),

                  // ---- Movie list (mirrors UITableView) ----
                  Expanded(
                    child: RefreshIndicator(
                      color: const Color(0xFFE5B33A),
                      onRefresh: _onRefresh,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: vm.numberofMovies + (vm.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          // ---- Pagination loader ----
                          if (index == vm.numberofMovies) {
                            return const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFFE5B33A)),
                              ),
                            );
                          }

                          final movie = vm.getMovieAtIndex(index);
                          if (movie == null) return const SizedBox.shrink();

                          // ---- Movie card (mirrors MovieCellTemplate) ----
                          return GestureDetector(
                            onTap: () => _onMovieTapped(movie),
                            child: MovieCard(
                              backdropPath: movie.backdropPath,
                              title: movie.title,
                              starCount: movie.movieRating,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header  (mirrors navigationController?.setNavigationBarHidden + title)
// ---------------------------------------------------------------------------
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'La\'Pelicula',
                style: TextStyle(
                  color: Color(0xFFE5B33A),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Upcoming Movies',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const Icon(Icons.movie_filter_rounded,
              color: Color(0xFFE5B33A), size: 32),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error view
// ---------------------------------------------------------------------------
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white30, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5B33A),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}



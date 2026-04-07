import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/movie_details_model.dart';
import '../view_model/movie_details_view_model.dart';
import 'movie_details_image_view.dart';
import '../../../utilities/app_constants.dart';

/// Mirrors [MovieDetailsViewController + MovieDetailsView + MovedetailsImageView]
///
/// Flutter collapses the three iOS classes into one [StatelessWidget]:
///   - [MovedetailsImageView]      → [SliverAppBar] with [MovieDetailsImageView]
///   - [MovieDetailsView]          → scrollable panel with all detail rows
///   - [MovieDetailsViewController] → navigation / action wiring
///
/// Actions mirrored:
///   - Back button     → Navigator.pop  (navigatetoDashboard)
///   - IMDB button     → opens imdb.com in browser (navigatetoImdb)
///   - GET TICKETS btn → opens Cathay Cineplexes in browser (navigateToBookMovie)
class MovieDetailsScreen extends StatelessWidget {
  final MovieDetailsModel? movieDetailsModel;

  const MovieDetailsScreen({super.key, this.movieDetailsModel});

  // ---------------------------------------------------------------------------
  // URL launchers — mirror SFSafariViewController
  // ---------------------------------------------------------------------------
  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = MovieDetailsViewModel(details: movieDetailsModel);
    final display = viewModel.getMovieDetails();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: CustomScrollView(
        slivers: [
          // ---- Poster image (mirrors MovedetailsImageView) ----
          SliverAppBar(
            expandedHeight: 420,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F1A),
            leading: _BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: MovieDetailsImageView(
                posterPath: viewModel.posterPath,
              ),
            ),
          ),

          // ---- Details panel (mirrors MovieDetailsView) ----
          SliverToBoxAdapter(
            child: _MovieDetailsPanel(
              display: display,
              imdbId: viewModel.imdbId,
              onImdb: () {
                final id = viewModel.imdbId ?? '';
                if (id.isNotEmpty) {
                  _openUrl('${AppConstants.imdbUrl}$id');
                }
              },
              onGetTickets: () => _openUrl(AppConstants.bookmyShow),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Back button (mirrors backbutton in MovieDetailsView)
// ---------------------------------------------------------------------------
class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 18),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Details panel (mirrors MovieDetailsView scrollable content)
// ---------------------------------------------------------------------------
class _MovieDetailsPanel extends StatelessWidget {
  final MovieDetails? display;
  final String? imdbId;
  final VoidCallback onImdb;
  final VoidCallback onGetTickets;

  const _MovieDetailsPanel({
    required this.display,
    required this.imdbId,
    required this.onImdb,
    required this.onGetTickets,
  });

  @override
  Widget build(BuildContext context) {
    // Adds system nav bar height so the GET TICKETS button is never clipped
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF13131F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 24, 20, 32 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Title (mirrors title UILabel, font size 40 bold) ----
          Text(
            display?.title ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          // ---- Star rating + IMDB button row ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _StarRating(filled: display?.star ?? 1, total: 5),
              const SizedBox(width: 16),
              if (imdbId != null && imdbId!.isNotEmpty)
                GestureDetector(
                  onTap: onImdb,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5C518),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'IMDb',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // ---- Genre (mirrors genre label in green) ----
          if (display?.genre != null && display!.genre!.isNotEmpty)
            Text(
              display!.genre!,
              style: const TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

          const SizedBox(height: 16),

          // ---- Synopsis (mirrors synopsis UILabel, maxLines 5) ----
          if (display?.synopsis != null && display!.synopsis!.isNotEmpty)
            Text(
              display!.synopsis!,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.6,
              ),
            ),

          const SizedBox(height: 20),

          // ---- Release date row ----
          _InfoRow(
            label: 'Releases On:',
            value: display?.releaseDate ?? 'N/A',
          ),

          const SizedBox(height: 10),

          // ---- Runtime row ----
          _InfoRow(
            label: 'Runtime:',
            value: display?.runtime ?? 'N/A',
          ),

          const SizedBox(height: 36),

          // ---- GET TICKETS button ----
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE5B33A), width: 1.5),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              onPressed: onGetTickets,
              child: const Text('GET TICKETS'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Info row widget (mirrors releaselabel + releaseDate / runtimeLabel + runtime)
// ---------------------------------------------------------------------------
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Star rating (mirrors RatingView array, size 40 in iOS)
// ---------------------------------------------------------------------------
class _StarRating extends StatelessWidget {
  final int filled;
  final int total;
  const _StarRating({required this.filled, this.total = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        return Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Icon(
            i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: const Color(0xFFE5B33A),
            size: 28,
          ),
        );
      }),
    );
  }
}

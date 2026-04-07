import 'package:flutter/material.dart';

import '../../../utilities/app_constants.dart';

/// Mirrors [MovieCellTemplate.swift]
///
/// A card-style widget that displays:
///   - Movie backdrop image (from TMDB)
///   - Movie title overlaid on the image
///   - Star rating row (1-4 filled stars out of 4)
class MovieCard extends StatelessWidget {
  final String? backdropPath;
  final String? title;
  final int starCount; // 1 – 4

  const MovieCard({
    super.key,
    this.backdropPath,
    this.title,
    required this.starCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // ---- Backdrop image ----
            _BackdropImage(backdropPath: backdropPath),

            // ---- Dark gradient so text is readable ----
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),
            ),

            // ---- Title + star rating ----
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StarRating(filled: starCount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Backdrop image widget
// ---------------------------------------------------------------------------
class _BackdropImage extends StatelessWidget {
  final String? backdropPath;
  const _BackdropImage({this.backdropPath});

  @override
  Widget build(BuildContext context) {
    final imageUrl = backdropPath != null
        ? '${AppConstants.shortImageURL}$backdropPath'
        : null;

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _placeholder(),
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _placeholder(loading: true);
              },
            )
          : _placeholder(),
    );
  }

  Widget _placeholder({bool loading = false}) {
    return Container(
      color: const Color(0xFF1C1C2E),
      child: Center(
        child: loading
            ? const CircularProgressIndicator(color: Color(0xFFE5B33A))
            : const Icon(Icons.movie_outlined, color: Colors.white30, size: 48),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Star rating row (mirrors the RatingView array in MovieCellTemplate)
// ---------------------------------------------------------------------------
class _StarRating extends StatelessWidget {
  final int filled; // how many filled stars (1-4)
  const _StarRating({required this.filled});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            i < filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: const Color(0xFFE5B33A),
            size: 20,
          ),
        );
      }),
    );
  }
}

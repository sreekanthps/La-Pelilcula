import 'package:flutter/material.dart';

import '../../../utilities/app_constants.dart';

/// Mirrors [MovedetailsImageView.swift]
///
/// Full-screen poster image that sits behind the scrollable details panel.
/// In Flutter this is a [SliverAppBar] with an expandable image that
/// collapses as the user scrolls up — giving a smooth parallax effect
/// that mirrors the iOS stacked-view approach.
class MovieDetailsImageView extends StatelessWidget {
  /// Poster path, e.g. "/abc123.jpg"
  final String? posterPath;

  const MovieDetailsImageView({super.key, this.posterPath});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (posterPath != null && posterPath!.isNotEmpty)
        ? '${AppConstants.shortImageURL}$posterPath'
        : null;

    return SizedBox.expand(
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _placeholder(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
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
            : const Icon(Icons.movie_outlined, color: Colors.white24, size: 64),
      ),
    );
  }
}

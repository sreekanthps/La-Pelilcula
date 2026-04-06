import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Flutter equivalent of SplashViewController from LaPelicula-main.
/// Plays [splashanimation.json] once via Lottie, then navigates to [nextScreen].
class SplashScreen extends StatefulWidget {
  /// The widget to navigate to after the animation completes.
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Listen for animation completion to trigger navigation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.nextScreen,
        // Smooth fade transition, matching the iOS `animated: false` feel
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/animations/splashanimation.json',
          controller: _controller,
          width: 300,
          height: 300,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            // Set the duration from the JSON composition and play once
            _controller
              ..duration = composition.duration
              ..forward();
          },
        ),
      ),
    );
  }
}

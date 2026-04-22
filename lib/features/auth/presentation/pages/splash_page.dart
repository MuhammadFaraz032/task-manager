import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  // LEARNING: We extracted navigation logic into its own method.
  // Keeps initState() clean and readable.
  Future<void> _navigateToNext() async {
    // Trigger auth check immediately in background
    // so BLoCs are warm by the time splash ends
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const AuthCheckRequested());
    });

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    if (isLoggedIn) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      // LEARNING: SizedBox.expand() fills the entire screen
      // regardless of device size. Always use this instead of
      // hardcoded width/height for full-screen widgets.
      body: SizedBox.expand(
        child: Stack(
          children: [
            /// Top right blur circle
            Positioned(
              right: -128,
              top: -128,
              child: _blurCircle(
                size: 384,
                color: cs.primary.withValues(alpha: 0.1),
                blur: 60,
              ),
            ),

            /// Bottom left blur circle
            Positioned(
              left: -128,
              bottom: -128,
              child: _blurCircle(
                size: 384,
                color: cs.secondary.withValues(alpha: 0.1),
                blur: 60,
              ),
            ),

            /// Center ambient glow
            Center(
              child: _blurCircle(
                size: 500,
                color: cs.primary.withValues(alpha: 0.5),
                blur: 75,
              ),
            ),

            /// Main Content
            Positioned.fill(
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  _iconSection(cs),

                  const SizedBox(height: 40),

                  _titleSection(cs),

                  const Spacer(),

                  LoadingProgressSection(colorScheme: cs),

                  const SizedBox(height: 40),

                  /// Home indicator bar
                  Container(
                    height: 32,
                    alignment: Alignment.center,
                    child: Container(
                      width: 128,
                      height: 6,
                      decoration: BoxDecoration(
                        color: cs.outline.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blurCircle({
    required double size,
    required Color color,
    required double blur,
  }) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _iconSection(ColorScheme cs) {
    return Stack(
      alignment: Alignment.center,
      children: [
        /// Outer glow
        _blurCircle(
          size: 144,
          color: cs.primary.withValues(alpha: 0.2),
          blur: 32,
        ),

        /// Glass backdrop
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.onSurface.withValues(alpha: 0.05)),
              ),
            ),
          ),
        ),

        /// Gradient icon box
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.brandGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.25),
                blurRadius: 50,
              ),
            ],
          ),
          child: const Icon(Icons.bolt, color: Colors.white, size: 40),
        ),
      ],
    );
  }

  Widget _titleSection(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            "Task Manager",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.9,
              color: cs.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Seamless Productivity",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 2.8,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// LEARNING: LoadingProgressSection is its own StatefulWidget
// because it has its own AnimationController lifecycle.
// Keeping animation state separate from page state is clean
// architecture — each widget manages only its own concerns.
class LoadingProgressSection extends StatefulWidget {
  final ColorScheme colorScheme;

  const LoadingProgressSection({super.key, required this.colorScheme});

  @override
  State<LoadingProgressSection> createState() => _LoadingProgressSectionState();
}

class _LoadingProgressSectionState extends State<LoadingProgressSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      // LEARNING: Animation duration matches the splash delay (3s)
      // so the bar fills exactly as navigation triggers.
      duration: const Duration(seconds: 3),
    );

    _animation =
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        )..addListener(() {
          setState(() {});
        });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final percent = (_animation.value * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "INITIALIZING",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: cs.onSurface.withValues(alpha: 0.4),
                ),
              ),
              Text(
                "$percent%",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Progress bar
          Stack(
            children: [
              /// Background track
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: cs.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              /// Filled portion
              // LEARNING: FractionallySizedBox is the correct way
              // to show a percentage-based width. Never use
              // double.infinity * progress — it evaluates to infinity.
              FractionallySizedBox(
                widthFactor: _animation.value,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.brandGradient,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              "PLEASE WAIT",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
                color: cs.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

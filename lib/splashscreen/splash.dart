import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:task_manager/loginscreen/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 7), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark 
          ? const Color(0xFF0F172A)  // Dark background
          : const Color(0xFFF8FAFC), // Light background
      body: SizedBox(
        width: 390,
        height: 884,
        child: Stack(
          children: [
            /// Top blur circle
            Positioned(
              right: -128,
              top: -128,
              child: _blurCircle(
                size: 384,
                color: (isDark ? const Color(0xFF2563EB) : const Color(0xFF3B82F6))
                    .withOpacity(0.1),
                blur: 60,
              ),
            ),

            /// Bottom blur circle
            Positioned(
              left: -128,
              bottom: -128,
              child: _blurCircle(
                size: 384,
                color: (isDark ? const Color(0xFF8B5CF6) : const Color(0xFFA78BFA))
                    .withOpacity(0.1),
                blur: 60,
              ),
            ),

            /// Center big blur
            Center(
              child: _blurCircle(
                size: 500,
                color: (isDark ? const Color(0xFF2563EB) : const Color(0xFF3B82F6))
                    .withOpacity(0.05),
                blur: 75,
              ),
            ),

            /// Main Content
            Positioned.fill(
              child: Column(
                children: [
                  const SizedBox(height: 80),

                  /// Icon Section
                  _iconSection(isDark),

                  const SizedBox(height: 40),

                  /// Title Section
                  _titleSection(isDark),

                  const Spacer(),

                  /// Progress Section
                  LoadingProgressSection(isDark: isDark),

                  const SizedBox(height: 40),

                  /// Bottom Indicator
                  Container(
                    height: 32,
                    alignment: Alignment.center,
                    child: Container(
                      width: 128,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark 
                            ? const Color(0xFF1E293B).withOpacity(0.5)
                            : const Color(0xFFE2E8F0).withOpacity(0.5),
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

  /// Blur Circle Widget
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

  /// Icon Section
  Widget _iconSection(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        /// Outer blurred glow
        _blurCircle(
          size: 144,
          color: (isDark ? const Color(0xFF2563EB) : const Color(0xFF3B82F6))
              .withOpacity(0.2),
          blur: 32,
        ),

        /// Glass border effect
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: isDark 
                    ? const Color(0xFF1E293B).withOpacity(0.4)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ),

        /// Gradient Icon Box
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF2563EB) : const Color(0xFF3B82F6))
                    .withOpacity(0.25),
                blurRadius: 50,
              ),
            ],
          ),
          child: const Icon(Icons.bolt, color: Colors.white, size: 40),
        ),
      ],
    );
  }

  /// Title Section
  Widget _titleSection(bool isDark) {
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
              color: isDark 
                  ? const Color(0xFFF1F5F9)   // Dark mode text
                  : const Color(0xFF1E293B),  // Light mode text
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Seamless Productivity",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 2.8,
              color: isDark 
                  ? const Color(0xFF94A3B8)   // Dark mode secondary
                  : const Color(0xFF64748B),  // Light mode secondary
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingProgressSection extends StatefulWidget {
  final bool isDark;
  
  const LoadingProgressSection({super.key, required this.isDark});

  @override
  State<LoadingProgressSection> createState() => _LoadingProgressSectionState();
}

class _LoadingProgressSectionState extends State<LoadingProgressSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
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
    final percent = (_animation.value * 100).toInt();
    final isDark = widget.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "INITIALIZING",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: isDark 
                      ? const Color(0xFF64748B)  // Dark mode
                      : const Color(0xFF94A3B8), // Light mode
                ),
              ),
              Text(
                "$percent%",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB), // Primary color (same for both)
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Progress Bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF1E293B)   // Dark surface
                      : const Color(0xFFE2E8F0),  // Light border
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              FractionallySizedBox(
                widthFactor: _animation.value,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
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
                color: isDark 
                    ? const Color(0xFF475569)   // Dark text secondary
                    : const Color(0xFF94A3B8),  // Light text disabled
              ),
            ),
          ),
        ],
      ),
    );
  }
}
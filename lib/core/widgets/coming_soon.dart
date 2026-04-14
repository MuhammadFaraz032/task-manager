import 'package:flutter/material.dart';

class ComingSoon extends StatelessWidget {
  final String? pageName;
  final IconData? icon;
  
  const ComingSoon({
    super.key,
    this.pageName,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // final screenSize = MediaQuery.of(context).size;
    
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                builder: (context, double scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2563EB).withValues(alpha: 0.2),
                            const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon ?? Icons.construction,
                        size: 60,
                        color: isDark 
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // "Coming Soon" text with shimmer effect
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
                ).createShader(bounds),
                child: const Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Page name
              if (pageName != null)
                Text(
                  pageName!,
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark 
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Progress indicator
              Container(
                width: 200,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.0, end: 0.3),
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  builder: (context, double value, child) {
                    return FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Description
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark 
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 20,
                          color: isDark 
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Under Development',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark 
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This page is being built. Check back soon!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark 
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/auth/presentation/widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Replace with AuthBloc event in Step 5
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      // LEARNING: resizeToAvoidBottomInset (true by default) pushes
      // the body up when the keyboard opens. Combined with
      // SingleChildScrollView below, this prevents overflow.
      resizeToAvoidBottomInset: true,
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.2,
            colors: [cs.primary.withOpacity(0.12), Colors.transparent],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // LEARNING: onDrag dismisses keyboard when user
            // scrolls down — better UX than tapping away
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                // LEARNING: minHeight ensures the Column fills
                // full screen on large phones so the Spacer
                // still pushes the footer to the bottom.
                // Without this, Spacer has nothing to expand
                // against inside a ScrollView.
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  // LEARNING: IntrinsicHeight makes the Column
                  // take the height of its tallest child.
                  // Required for Spacer to work inside
                  // a ConstrainedBox inside a ScrollView.
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      /// Logo
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.brandGradient,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Sign in to continue",
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// Email Field
                      AuthTextField(
                        label: "Email",
                        hint: "name@example.com",
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// Password Field
                      AuthTextField(
                        label: "Password",
                        hint: "••••••••",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      /// Sign In Button
                      InkWell(
                        onTap: _onSignIn,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.brandGradient,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Sign In",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: cs.outline)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                color: cs.onSurface.withOpacity(0.6),
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: cs.outline)),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// Google Sign In
                      InkWell(
                        onTap: () {
                          // TODO: Google sign in — Phase 2
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: cs.outline),
                          ),
                          child: Center(
                            child: Text(
                              "Continue with Google",
                              style: TextStyle(
                                color: cs.onSurface.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      /// Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                                color: cs.onSurface.withOpacity(0.6)),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              // TODO: context.go('/register')
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
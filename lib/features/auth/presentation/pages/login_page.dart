import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_event.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/auth/presentation/widgets/auth_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // LEARNING: BlocProvider creates a NEW AuthBloc instance
    // for this screen using getIt (our service locator)
    // When this screen is disposed, the bloc is closed automatically
    return const _LoginView();
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
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

  void _onLogin(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      // LEARNING: context.read<AuthBloc>() finds the AuthBloc
      // provided above and adds a LoginRequested event to it
      // This triggers _onLoginRequested in auth_bloc.dart
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // LEARNING: BlocListener listens to state changes
    // and performs side effects like navigation or showing snackbars
    // It does NOT rebuild the UI — that's BlocBuilder's job
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/dashboard');
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: cs.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        resizeToAvoidBottomInset: true,
        body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.2,
              colors: [cs.primary.withValues(alpha: 0.12), Colors.transparent],
            ),
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 80),

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
                                color: cs.primary.withValues(alpha: 0.3),
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
                            color: cs.onSurface.withValues(alpha: 0.6),
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 40),

                        /// Email
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

                        /// Password
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

                        const SizedBox(height: 32),

                        /// Login Button
                        // LEARNING: BlocBuilder rebuilds ONLY this
                        // button when auth state changes
                        // So the loading spinner shows only here
                        // while the rest of the UI stays the same
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return InkWell(
                              onTap: isLoading
                                  ? null
                                  : () => {
                                      FocusScope.of(context).unfocus(),
                                      _onLogin(context),
                                    },
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
                                      color: cs.primary.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          "Sign In",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        /// Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: cs.outline)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                "OR",
                                style: TextStyle(
                                  color: cs.onSurface.withValues(alpha: 0.6),
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
                            // TODO: Google Sign In — Phase 2
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
                                  color: cs.onSurface.withValues(alpha: 0.8),
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
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => context.go('/register'),
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

                        const SizedBox(height: 32),
                      ],
                    ),
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

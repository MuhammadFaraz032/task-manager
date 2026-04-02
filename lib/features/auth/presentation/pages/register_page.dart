import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager/core/theme/themecolors.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_event.dart';
import 'package:task_manager/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_manager/features/auth/presentation/widgets/auth_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RegisterView();
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        // if (state is AuthAuthenticated) {
        //   // LEARNING: After register → auto create workspace
        //   // using the user's name + "Workspace" as the name
        //   // This is transparent to the user — they never see this step
        //   context.read<WorkspaceCubit>().createWorkspace(
        //     name: "${state.user.fullName}'s Workspace",
        //     ownerId: state.user.uid,
        //   );
        //   context.go('/dashboard');
        // }
        if (state is AuthAuthenticated) {
          context.go('/dashboard');
        }
        // print('🟡 Auth state changed: $state');
        // if (state is AuthAuthenticated) {
        //   await context.read<WorkspaceCubit>().createWorkspace(
        //     name: "${state.user.fullName}'s Workspace",
        //     ownerId: state.user.uid,
        //   );
        //   if (context.mounted) {
        //     context.go('/dashboard');
        //   }
        // }
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
              center: Alignment.topLeft,
              radius: 1.2,
              colors: [
                cs.secondary.withValues(alpha: 0.12),
                Colors.transparent,
              ],
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
                                color: cs.secondary.withValues(alpha: 0.3),
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
                          "Create Account",
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Start managing your work better",
                          style: TextStyle(
                            color: cs.onSurface.withValues(alpha: 0.6),
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 40),

                        AuthTextField(
                          label: "Full Name",
                          hint: "Faraz Ahmed",
                          icon: Icons.person_outline_rounded,
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Full name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Enter a valid name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

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

                        const SizedBox(height: 20),

                        AuthTextField(
                          label: "Confirm Password",
                          hint: "••••••••",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          controller: _confirmPasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        /// Register Button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is AuthLoading;
                            return InkWell(
                              onTap: isLoading
                                  ? null
                                  : () => {
                                      FocusScope.of(context).unfocus(),
                                      _onRegister(context),
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
                                          "Create Account",
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: TextStyle(
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () => context.go('/login'),
                              borderRadius: BorderRadius.circular(4),
                              child: Text(
                                "Sign In",
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
      ),
    );
  }
}

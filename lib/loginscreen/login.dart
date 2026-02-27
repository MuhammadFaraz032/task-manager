import 'package:flutter/material.dart';
import 'package:task_manager/dashboard/dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailcontroller = TextEditingController();
    final passswordcontroller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SafeArea(
      child: Scaffold(
        backgroundColor: isDark 
            ? const Color(0xFF0F172A)  // Dark background
            : const Color(0xFFF8FAFC), // Light background
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.2,
              colors: [
                isDark 
                    ? const Color.fromRGBO(37, 99, 235, 0.15)
                    : const Color.fromRGBO(59, 130, 246, 0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                /// Logo
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: isDark 
                              ? Colors.black.withOpacity(0.5)
                              : Colors.black.withOpacity(0.2),
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
                ),

                const SizedBox(height: 32),

                /// Header
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: isDark 
                        ? const Color(0xFFF1F5F9)   // Dark text
                        : const Color(0xFF1E293B),  // Light text
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Sign in to continue",
                  style: TextStyle(
                    color: isDark 
                        ? const Color(0xFF94A3B8)   // Dark secondary
                        : const Color(0xFF64748B),  // Light secondary
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                /// Email Field
                AuthTextField(
                  label: "Email",
                  hint: "name@example.com",
                  icon: Icons.email_outlined,
                  controller: emailcontroller,
                  isDark: isDark,
                ),

                const SizedBox(height: 20),

                /// Password Field
                AuthTextField(
                  label: "Password",
                  hint: "••••••••",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  controller: passswordcontroller,
                  isDark: isDark,
                ),

                const SizedBox(height: 24),

                /// Sign In Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const MainDashboard(),
                      ),
                    );
                  },
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isDark 
                              ? const Color.fromRGBO(59, 130, 246, 0.5)
                              : const Color.fromRGBO(59, 130, 246, 0.3),
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
                    Expanded(
                      child: Divider(
                        color: isDark 
                            ? const Color(0xFF334155)   // Dark border
                            : const Color(0xFFE2E8F0),  // Light border
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "OR",
                        style: TextStyle(
                          color: isDark 
                              ? const Color(0xFF94A3B8)   // Dark secondary
                              : const Color(0xFF64748B),  // Light secondary
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark 
                            ? const Color(0xFF334155)   // Dark border
                            : const Color(0xFFE2E8F0),  // Light border
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// Social Login Button
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark 
                          ? const Color(0xFF334155)   // Dark border
                          : const Color(0xFFE2E8F0),  // Light border
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "Continue with Google",
                      style: TextStyle(
                        color: isDark 
                            ? const Color(0xFFE2E8F0)   // Dark text
                            : const Color(0xFF475569),  // Light text
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                        color: isDark 
                            ? const Color(0xFF94A3B8)   // Dark secondary
                            : const Color(0xFF64748B),  // Light secondary
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Sign Up",
                      style: TextStyle(
                        color: isDark 
                            ? const Color(0xFF60A5FA)   // Dark primary (brighter)
                            : const Color(0xFF2563EB),  // Light primary
                        fontWeight: FontWeight.bold,
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
    );
  }
}

class AuthTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController controller;
  final bool isDark;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    required this.isDark,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: widget.isDark 
                ? const Color(0xFFCBD5E1)   // Dark text
                : const Color(0xFF64748B),  // Light text
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: MediaQuery.of(context).size.width - 20,
          height: 56,
          decoration: BoxDecoration(
            color: widget.isDark 
                ? const Color(0xFF1E293B)   // Dark surface
                : const Color(0xFFFFFFFF),  // Light surface
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isDark 
                  ? const Color(0xFF334155)   // Dark border
                  : const Color(0xFFE2E8F0),  // Light border
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword ? obscure : false,
            style: TextStyle(
              color: widget.isDark 
                  ? Colors.white
                  : const Color(0xFF1E293B),
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: widget.isDark 
                    ? const Color(0xFF6B7280)   // Dark hint
                    : const Color(0xFF94A3B8),  // Light hint
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                widget.icon, 
                color: widget.isDark 
                    ? const Color(0xFF94A3B8)   // Dark icon
                    : const Color(0xFF64748B),  // Light icon
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: widget.isDark 
                            ? const Color(0xFF94A3B8)   // Dark icon
                            : const Color(0xFF64748B),  // Light icon
                      ),
                      onPressed: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),
      ],
    );
  }
}
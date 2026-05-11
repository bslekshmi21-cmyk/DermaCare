
import 'package:adminapp/addpro.dart';
import 'package:adminapp/home.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _loading = false;
  bool _isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      // 1. Authenticate with Supabase Auth
      final authResponse = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = authResponse.user; // FIXED: Changed .admin to .user
      print(user);
      if (user == null) throw Exception("Authentication failed");

      // 2. Check if user exists in the admin database table
      final response = await supabase
          .from('tbl_admin')
          .select()
          .eq('admin_id', user.id)
          .maybeSingle();
          print(response);


      if (response != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const dash()),
          );
        }
      } 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            content: Text(e.toString().replaceAll('Exception: ', '')),
          ),
        );
      }
      print("Error $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // UI Theme Colors
  final Color primaryNavy = const Color(0xFF1E293B);
  final Color accentBlue = const Color(0xFF2563EB);
  final Color bgSlate = const Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSlate,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Logo Section
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  size: 45,
                  color: accentBlue,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Admin Portal",
                style: TextStyle(
                  color: primaryNavy,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 40),

              // Form Card
              Container(
                constraints: const BoxConstraints(maxWidth: 450),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildClassicField(
                        controller: _emailController,
                        label: "Email Address",
                        hint: "admin@company.com",
                        icon: Icons.alternate_email_rounded,
                        type: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      _buildClassicField(
                        controller: _passwordController,
                        label: "Password",
                        hint: "Enter password",
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        obscure: !_isPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryNavy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassicField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? type,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: primaryNavy,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: type,
          validator: (value) {
            if (value == null || value.isEmpty) return "Field required";
            if (label.contains("Email") && !value.contains("@"))
              return "Invalid email";
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: bgSlate,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accentBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
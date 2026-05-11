import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:userapp/main.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final Color primary = const Color(0xFF2E7431);

  bool _loading = false;

  final TextEditingController _securityKeyController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _handleReset() async {
    final securityKey = _securityKeyController.text.trim();
    final newPassword = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (securityKey.isEmpty || newPassword.isEmpty) {
      _showSnackBar("Please fill all fields", Colors.orange);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnackBar("Passwords do not match", Colors.redAccent);
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await supabase
          .from('tbl_user')
          .select('user_id')
          .eq('user_securitykey', securityKey)
          .eq('user_status', 'active')
          .maybeSingle();

      if (response == null) {
        throw Exception("Invalid Security Key or Unauthorized User");
      }

      final userId = response['user_id'];

      await supabase
          .from('tbl_user')
          .update({'user_password': newPassword})
          .eq('user_id', userId);

      await supabase.auth.updateUser(UserAttributes(password: newPassword));

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showSnackBar(e.toString(), Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Success",
          textAlign: TextAlign.center,
          style: TextStyle(color: primary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Password updated successfully",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                "OK",
                style: TextStyle(color: primary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration buildInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primary),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _securityKeyController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 340,
            child: Card(
              elevation: 10,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    Icon(Icons.lock_reset, size: 65, color: primary),

                    const SizedBox(height: 15),

                    Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Recover your account access",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 30),

                    TextFormField(
                      controller: _securityKeyController,
                      decoration: buildInput(
                        "Security Key",
                        Icons.vpn_key_rounded,
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: buildInput("New Password", Icons.lock),
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: buildInput(
                        "Confirm Password",
                        Icons.lock_outline,
                      ),
                    ),

                    const SizedBox(height: 25),

                    _loading
                        ? CircularProgressIndicator(color: primary)
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _handleReset,
                              child: const Text(
                                "UPDATE PASSWORD",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                    const SizedBox(height: 15),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Back to Login",
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

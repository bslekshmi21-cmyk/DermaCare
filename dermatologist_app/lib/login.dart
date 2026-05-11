import 'package:dermatologist_app/forgotpass.dart';
import 'package:dermatologist_app/indexpage.dart';
import 'package:dermatologist_app/register.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;
  bool isLoading = false;

  final supabase = Supabase.instance.client;

  Future<void> loginUser() async {
    try {
      setState(() {
        isLoading = true;
      });

      // 1. Authenticate with Supabase Auth
      final authResponse = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = authResponse.user;

      if (user == null) {
        throw Exception("Login failed");
      }

      // 2. Fetch Dermatologist data
      final data = await supabase
          .from('tbl_dermatologist')
          .select()
          .eq('dermatologist_id', user.id)
          .maybeSingle();

      if (data == null) {
        throw Exception("Dermatologist profile not found");
      }

      // 3. Status Check Logic
      final String status = (data['dermatologist_status'] ?? "pending").toString().toLowerCase();

      if (status == "inactive") {
        // Sign out if blocked
        await supabase.auth.signOut();
        if (mounted) {
          showSnackBar("Your account has been blocked by admin", Colors.red);
        }
      } else if (status == "pending") {
        // Sign out if still pending approval
        await supabase.auth.signOut();
        if (mounted) {
          showSnackBar("Your account is still pending approval", Colors.orange);
        }
      } else if (status == "active") {
        // Navigate only if active
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const IndexPage()),
          );
        }
      } else {
        // Safety check for any other value
        await supabase.auth.signOut();
        if (mounted) {
          showSnackBar("Unauthorized access status", Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(e.toString(), Colors.black);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  InputDecoration customInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF0A6C74)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF0A6C74),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDF5F7),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    size: 45,
                    color: Color(0xFF0A6C74),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "DermaCare",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A6C74),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Welcome back! Login to continue",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                ),
                const SizedBox(height: 35),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: customInputDecoration(
                          hint: "Email Address",
                          icon: Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: customInputDecoration(
                          hint: "Password",
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => obscurePassword = !obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                activeColor: const Color(0xFF0A6C74),
                                onChanged: (value) => setState(() => rememberMe = value!),
                              ),
                              const Text("Remember me", style: TextStyle(fontSize: 13)),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ForgetPassword(),));
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Color(0xFF0A6C74), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A6C74),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: isLoading ? null : loginUser,
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Log In",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?", style: TextStyle(color: Colors.grey)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Register(),));
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Color(0xFF0A6C74), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
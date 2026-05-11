import 'package:flutter/material.dart';
import 'package:userapp/createac.dart';
import 'package:userapp/fordpass.dart';
import 'package:userapp/index.dart';
import 'package:userapp/main.dart';
import 'package:userapp/register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final Color primary = const Color(0xFF2E7431);

  Future<void> loginUser() async {
    try {
      // 1. Attempt Authentication
      final authResponse = await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = authResponse.user;
      if (user == null) throw Exception("Login failed");

      // 2. Fetch User Status from Database
      final response = await supabase
          .from('tbl_user')
          .select('user_status')
          .eq('user_id', user.id)
          .single();

      // Check for null or the specific status string
      String? status = response['user_status']?.toString().toLowerCase();

      // 3. Logic for Status Filtering
      if (status == "inactive") {
        // Log them out immediately if inactive
        await supabase.auth.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account blocked by admin"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (status == "pending" || status == null || status == "") {
        // If status is pending or completely empty/null, don't let them in
        await supabase.auth.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account pending approval"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else if (status == "active") {
        // ONLY go to IndexPage if status is explicitly "active"
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const IndexPage()),
          );
        }
      } else {
        // Catch-all for any other status that isn't 'active'
        await supabase.auth.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unauthorized status")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
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
    );
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
                    Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Login to continue",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: emailController,
                      decoration: buildInput("Email Address", Icons.email),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: buildInput("Password", Icons.lock),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ForgetPassword()),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: loginUser,
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Register(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(color: primary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Or continue with",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.facebook, color: Colors.blue, size: 30),
                        SizedBox(width: 15),
                        Icon(Icons.apple, size: 30),
                      ],
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
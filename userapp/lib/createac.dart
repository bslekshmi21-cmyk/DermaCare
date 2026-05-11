import 'package:flutter/material.dart';
import 'package:userapp/login.dart';

class Createac extends StatefulWidget {
  const Createac({super.key});

  @override
  State<Createac> createState() => _CreateacState();
}

class _CreateacState extends State<Createac> {
  final Color primary = const Color(0xFF2E7431);

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
          child: Container(
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

                    /// TITLE
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Create a new account to continue",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 25),

                    /// NAME
                    TextFormField(
                      decoration: buildInput("Name", Icons.person),
                    ),

                    const SizedBox(height: 15),

                    /// EMAIL
                    TextFormField(
                      decoration: buildInput("Email Address", Icons.email),
                    ),

                    const SizedBox(height: 15),

                    /// PASSWORD
                    TextFormField(
                      obscureText: true,
                      decoration: buildInput("Password", Icons.lock),
                    ),

                    const SizedBox(height: 15),

                    /// CONFIRM PASSWORD
                    TextFormField(
                      obscureText: true,
                      decoration: buildInput("Confirm Password", Icons.lock),
                    ),

                    const SizedBox(height: 20),

                    /// CREATE BUTTON
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        child: const Text(
                          "CREATE ACCOUNT",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// LOGIN LINK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                            );
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(color: primary),
                          ),
                        ),
                      ],
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
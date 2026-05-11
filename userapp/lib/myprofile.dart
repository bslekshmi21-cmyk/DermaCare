import 'package:flutter/material.dart';
import 'package:userapp/changepass.dart';
import 'package:userapp/complaint.dart';
import 'package:userapp/editprof.dart';
import 'package:userapp/feedbackpage.dart';
import 'package:userapp/login.dart';
import 'package:userapp/main.dart' hide supabase;
import 'package:userapp/register.dart';

class Myprofile extends StatefulWidget {
  const Myprofile({super.key});

  @override
  State<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends State<Myprofile> {
  String name = "";
  String photo = "";
  String email = "";
  String address = "";
  String contact = "";

  bool isLoading = true;

  Future<void> loadProfile() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        print("No user logged in");
        return;
      }

      print("AUTH ID: ${user.id}");

      final response = await supabase
          .from('tbl_user')
          .select()
          .eq('user_id', user.id)
          .maybeSingle(); // ✅ FIXED

      print("PROFILE DATA: $response");

      if (response != null) {
        setState(() {
          name = response['user_name'] ?? "";
          photo = response['user_photo'] ?? "";
          email = response['user_email'] ?? "";
          address = response['user_address'] ?? "";
          contact = response['user_contact'] ?? "";
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("No profile found in tbl_user");
      }
    } catch (e) {
      print("Profile Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Widget buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text.isEmpty ? "-" : text,
              style: const TextStyle(color: Colors.blueGrey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Container(
                  width: 500,
                  padding: const EdgeInsets.all(16),

                  child: Card(
                    elevation: 12,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),

                        /// PROFILE IMAGE
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: photo.isNotEmpty
                              ? NetworkImage(photo)
                              : null,
                          child: photo.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                )
                              : null,
                        ),

                        const SizedBox(height: 15),

                        /// NAME
                        Text(
                          name.isEmpty ? "No Name" : name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(),

                        buildInfoRow(Icons.email_outlined, email),
                        buildInfoRow(Icons.call, contact),
                        buildInfoRow(Icons.home, address),

                        const SizedBox(height: 10),
                        const Divider(),

                        /// BUTTONS
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Editprof(),
                                        ),
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          color: Colors.blueGrey,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Edit Profile',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Changepass(),
                                        ),
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.visibility,
                                          color: Colors.blueGrey,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Change Password',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Complaint(),
                                        ),
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.help,
                                          color: Colors.blueGrey,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Complaint',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FeedbackPage(),
                                        ),
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.feedback,
                                          color: Colors.blueGrey,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Feedback',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  TextButton(
                                    onPressed: () async {
                                      await supabase.auth.signOut();

                                      if (!context.mounted) return;

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Login(),
                                        ),
                                      );
                                    },
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.logout,
                                          color: Colors.blueGrey,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Logout',
                                          style: TextStyle(
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

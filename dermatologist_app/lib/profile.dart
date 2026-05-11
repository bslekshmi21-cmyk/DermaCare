import 'package:dermatologist_app/changepfp.dart';
import 'package:dermatologist_app/editpf.dart';
import 'package:dermatologist_app/login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final supabase = Supabase.instance.client;

  String name = "";
  String photo = "";
  String email = "";
  String experience = "";
  String contact = "";

  bool isLoading = true;

  Future<void> fetchProfile() async {
    try {
      final dermo = supabase.auth.currentUser;

      if (dermo == null) return;

      final response = await supabase
          .from('tbl_dermatologist')
          .select()
          .eq('dermatologist_id', dermo.id)
          .single();

      setState(() {
        name = response['dermatologist_name'] ?? "";

        photo = response['dermatologist_photo'] ?? "";

        email = response['dermatologist_email'] ?? "";

        experience = response['dermatologist_experience'].toString();

        contact = response['dermatologist_contact'] ?? "";

        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFF4F7FB),

        iconTheme: const IconThemeData(color: Color(0xFF0A6C74)),

        title: const Text(
          "Profile",
          style: TextStyle(
            color: Color(0xFF0A6C74),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(25),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(22),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),

                        blurRadius: 10,

                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFF0A6C74),

                        backgroundImage: photo.isNotEmpty
                            ? NetworkImage(photo)
                            : null,

                        child: photo.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 55,
                                color: Colors.white,
                              )
                            : null,
                      ),

                      const SizedBox(height: 18),

                      /// NAME
                      Text(
                        name,

                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A6C74),
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Dermatologist",

                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// EMAIL
                      profileTile(icon: Icons.email_outlined, value: email),

                      const SizedBox(height: 15),

                      /// CONTACT
                      profileTile(icon: Icons.phone, value: contact),

                      const SizedBox(height: 15),

                      /// EXPERIENCE
                      profileTile(
                        icon: Icons.work_history_outlined,

                        value: "$experience Years Experience",
                      ),

                      const SizedBox(height: 30),

                      /// BUTTONS
                      Row(
                        children: [
                          /// EDIT PROFILE
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A6C74),

                                elevation: 0,

                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),

                              onPressed: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (context) => const Editpf(),
                                  ),
                                );
                              },

                              child: const Text(
                                "Edit Profile",

                                style: TextStyle(
                                  color: Colors.white,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// CHANGE PASSWORD
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF0A6C74),
                                ),

                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),

                              onPressed: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (context) => const Changepass(),
                                  ),
                                );
                              },

                              child: const Text(
                                "Change Password",

                                textAlign: TextAlign.center,

                                style: TextStyle(
                                  color: Color(0xFF0A6C74),

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          /// CHANGE PASSWORD
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF0A6C74),
                                ),

                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),

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

                              child: const Text(
                                "Logout",

                                textAlign: TextAlign.center,

                                style: TextStyle(
                                  color: Color(0xFF0A6C74),

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget profileTile({required IconData icon, required String value}) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),

        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0A6C74)),

          const SizedBox(width: 15),

          Expanded(
            child: Text(
              value,

              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF0A6C74),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

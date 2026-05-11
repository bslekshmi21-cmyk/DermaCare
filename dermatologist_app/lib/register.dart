import 'dart:typed_data';

import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late final supabase = Supabase.instance.client;

  Uint8List? imageBytes;
  file_picker.PlatformFile? pickedImage;

  Uint8List? proofBytes;
  file_picker.PlatformFile? pickedProof;

  final TextEditingController nameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController contactController = TextEditingController();

  final TextEditingController experienceController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController securityKeyController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  /// REGISTER
  Future<void> insert() async {
    try {
      setState(() {
        isLoading = true;
      });

      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final contact = contactController.text.trim();
      final experience = experienceController.text.trim();
      final password = passwordController.text.trim();
      final security = securityKeyController.text.trim();

      if (imageBytes == null) {
        showSnack("Please upload profile image");
        return;
      }

      if (proofBytes == null) {
        showSnack("Please upload proof document");
        return;
      }

      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final String? uid = authResponse.user?.id;

      if (uid == null) {
        throw Exception("Registration failed");
      }

      String? profileImageUrl = await photoUpload(uid);

      String? proofDocumentUrl = await proofUpload(uid);

      await supabase.from('tbl_dermatologist').insert({
        'dermatologist_id': uid,
        'dermatologist_name': name,
        'dermatologist_email': email,
        'dermatologist_contact': contact,
        'dermatologist_experience': experience,
        'dermatologist_password': password,
        'dermatologist_photo': profileImageUrl,
        'dermatologist_proof': proofDocumentUrl,
        'dermatologist_status': "Pending",
        'dermatologist_securitykey': securityKeyController.text, // ✅ ADDED HERE
      });

      showSnack("Registration successful!", isError: false);

      clearFields();
    } catch (e) {
      debugPrint(e.toString());

      showSnack("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// SNACKBAR
  void showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  /// CLEAR
  void clearFields() {
    nameController.clear();
    emailController.clear();
    contactController.clear();
    experienceController.clear();
    passwordController.clear();

    setState(() {
      imageBytes = null;
      proofBytes = null;

      pickedImage = null;
      pickedProof = null;
    });
  }

  /// PICK IMAGE
  Future<void> handleImagePick() async {
    final result = await file_picker.FilePicker.pickFiles(
      type: file_picker.FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
        imageBytes = pickedImage!.bytes;
      });
    }
  }

  /// PICK PROOF
  Future<void> handleProofPick() async {
    final result = await file_picker.FilePicker.pickFiles(
      type: file_picker.FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        pickedProof = result.files.first;
        proofBytes = pickedProof!.bytes;
      });
    }
  }

  /// PHOTO UPLOAD
  Future<String?> photoUpload(String uid) async {
    try {
      const bucket = 'dermotologist_photo';

      final path = "profile/$uid.${pickedImage!.extension}";

      await supabase.storage
          .from(bucket)
          .uploadBinary(
            path,
            imageBytes!,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      return supabase.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// PROOF UPLOAD
  Future<String?> proofUpload(String uid) async {
    try {
      const bucket = 'demotologist_proof';

      final path = "proof/$uid.${pickedProof!.extension}";

      await supabase.storage
          .from(bucket)
          .uploadBinary(
            path,
            proofBytes!,
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      return supabase.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    experienceController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  /// INPUT STYLE
  InputDecoration customDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(icon, color: const Color(0xFF0A6C74)),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: const Color(0xFFF4F7FB),

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
        borderSide: const BorderSide(color: Color(0xFF0A6C74), width: 1.5),
      ),
    );
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
          "Register",
          style: TextStyle(
            color: Color(0xFF0A6C74),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Container(
          padding: const EdgeInsets.all(22),

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
              /// PROFILE IMAGE
              GestureDetector(
                onTap: handleImagePick,

                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: const Color(0xFFDDF5F7),

                  backgroundImage: imageBytes != null
                      ? MemoryImage(imageBytes!)
                      : null,

                  child: imageBytes == null
                      ? const Icon(
                          Icons.camera_alt,
                          size: 35,
                          color: Color(0xFF0A6C74),
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Upload Profile Image",
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 25),

              /// PROOF BUTTON
              SizedBox(
                width: double.infinity,

                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),

                    side: const BorderSide(color: Color(0xFF0A6C74)),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  onPressed: handleProofPick,

                  icon: const Icon(Icons.upload_file, color: Color(0xFF0A6C74)),

                  label: Text(
                    pickedProof != null
                        ? pickedProof!.name
                        : "Upload Proof Document",

                    style: const TextStyle(color: Color(0xFF0A6C74)),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              /// NAME
              TextFormField(
                controller: nameController,

                decoration: customDecoration(
                  hint: "Name",
                  icon: Icons.person_outline,
                ),
              ),

              const SizedBox(height: 18),

              /// EMAIL
              TextFormField(
                controller: emailController,

                decoration: customDecoration(
                  hint: "Email Address",
                  icon: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 18),

              /// CONTACT
              TextFormField(
                controller: contactController,

                keyboardType: TextInputType.phone,

                decoration: customDecoration(
                  hint: "Contact Number",
                  icon: Icons.phone_outlined,
                ),
              ),

              const SizedBox(height: 18),

              /// EXPERIENCE
              TextFormField(
                controller: experienceController,

                decoration: customDecoration(
                  hint: "Years of Experience",
                  icon: Icons.work_outline,
                ),
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: securityKeyController,
                decoration: customDecoration(
                  hint: "Security Question",
                  icon: Icons.vpn_key,
                ),
              ),

              const SizedBox(height: 18),

              /// PASSWORD
              TextFormField(
                controller: passwordController,

                obscureText: obscurePassword,

                decoration: customDecoration(
                  hint: "Password",

                  icon: Icons.lock_outline,

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },

                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,

                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              /// REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0A6C74),

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  onPressed: isLoading ? null : insert,

                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Register",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

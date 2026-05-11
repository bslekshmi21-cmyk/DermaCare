import 'dart:typed_data';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:userapp/login.dart';
import 'package:userapp/main.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController securityKeyController = TextEditingController(); // ✅ ADDED

  List<Map<String, dynamic>> skinTypes = [];
  String? _selectedValue;
  String? selectedSkinTypeId;

  Uint8List? imageBytes;
  file_picker.PlatformFile? pickedImage;

  final Color primary = const Color(0xFF2E7431);

  @override
  void initState() {
    super.initState();
    fetchSkinTypes();
  }

  Future<void> fetchSkinTypes() async {
    try {
      final data = await supabase.from('tbl_type').select();
      setState(() {
        skinTypes = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint("Error fetching skin types: $e");
    }
  }

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

  Future<void> insert() async {
    try {
      final authResponse = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = authResponse.user?.id;
      if (uid == null) return;

      String? imageUrl;

      if (imageBytes != null && pickedImage != null) {
        final String fileName =
            '$uid-${DateTime.now().millisecondsSinceEpoch}.jpg';

        final String path = 'profile_images/$fileName';

        await supabase.storage.from('User').uploadBinary(
          path,
          imageBytes!,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );

        imageUrl = supabase.storage.from('User').getPublicUrl(path);
      }

      await supabase.from('tbl_user').insert({
        'user_id': uid,
        'user_name': nameController.text,
        'user_email': emailController.text,
        'user_contact': contactController.text,
        'user_address': addressController.text,
        'user_gender': _selectedValue,
        'type_id': selectedSkinTypeId,
        'user_photo': imageUrl,
        'user_password': passwordController.text,
        'user_securitykey': securityKeyController.text, // ✅ ADDED HERE
        'user_status': 0,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registered Successfully. Waiting for Admin Approval."),
        ),
      );

      // reset
      nameController.clear();
      emailController.clear();
      contactController.clear();
      addressController.clear();
      passwordController.clear();
      securityKeyController.clear(); // ✅ ADDED

      setState(() {
        _selectedValue = null;
        selectedSkinTypeId = null;
        imageBytes = null;
        pickedImage = null;
      });
    } catch (e) {
      debugPrint("Error: $e");
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  InputDecoration buildInput(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
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
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    contactController.dispose();
    addressController.dispose();
    passwordController.dispose();
    securityKeyController.dispose(); // ✅ ADDED
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
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: handleImagePick,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            imageBytes != null
                                ? MemoryImage(imageBytes!)
                                : null,
                        child: imageBytes == null
                            ? Icon(Icons.camera_alt, color: primary)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: nameController,
                      decoration: buildInput("Name", Icons.person),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: emailController,
                      decoration: buildInput("Email", Icons.email),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: contactController,
                      decoration: buildInput("Contact", Icons.call),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Text("Gender:", style: TextStyle(color: primary)),
                        Radio(
                          value: "Male",
                          groupValue: _selectedValue,
                          onChanged: (v) =>
                              setState(() => _selectedValue = v.toString()),
                        ),
                        const Text("Male"),
                        Radio(
                          value: "Female",
                          groupValue: _selectedValue,
                          onChanged: (v) =>
                              setState(() => _selectedValue = v.toString()),
                        ),
                        const Text("Female"),
                      ],
                    ),

                    DropdownButtonFormField<String>(
                      value: selectedSkinTypeId,
                      decoration: buildInput("Skin Type", Icons.category),
                      items: skinTypes.map((e) {
                        return DropdownMenuItem(
                          value: e['type_id'].toString(),
                          child: Text(e['type_name']),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setState(() => selectedSkinTypeId = v),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: addressController,
                      decoration: buildInput("Address", Icons.home),
                    ),

                    const SizedBox(height: 12),

                    // ✅ SECURITY KEY FIELD ADDED
                    TextFormField(
                      controller: securityKeyController,
                      decoration: buildInput(
                        "Security Key",
                        Icons.vpn_key,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: buildInput("Password", Icons.lock),
                    ),

                    const SizedBox(height: 20),

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
                        onPressed: insert,
                        child: const Text(
                          "REGISTER",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? "),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Login(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(color: primary),
                          ),
                        ),
                      ],
                    ),
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
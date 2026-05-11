import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

final supabase = Supabase.instance.client;

class Editprof extends StatefulWidget {
  const Editprof({super.key});

  @override
  State<Editprof> createState() => _EditprofState();
}

class _EditprofState extends State<Editprof> {
  final TextEditingController nameController = TextEditingController();

  final TextEditingController contactController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  Uint8List? imageBytes;
  PlatformFile? pickedImage;

  String? imageUrl;

  /// PICK IMAGE (FIXED)
  Future<void> pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
        imageBytes = pickedImage!.bytes;
      });
    }
  }

  /// LOAD PROFILE
  Future<void> loadProfile() async {
    try {
      final user = supabase.auth.currentUser;

      final response = await supabase
          .from('tbl_user')
          .select()
          .eq('user_id', user!.id)
          .single();

      setState(() {
        nameController.text = response['user_name'] ?? "";
        contactController.text = response['user_contact'] ?? "";
        addressController.text = response['user_address'] ?? "";
        imageUrl = response['user_photo'];
      });
    } catch (e) {
      debugPrint("Load Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// UPDATE PROFILE (FIXED 100%)
  Future<void> UpdateProfile() async {
    try {
      final user = supabase.auth.currentUser;

      String? finalImageUrl = imageUrl;

      /// UPLOAD IMAGE
      if (imageBytes != null) {
        final fileName =
            "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";

        final upload = await supabase.storage
            .from('profile_photo')
            .uploadBinary(
              fileName,
              imageBytes!,
              fileOptions: const FileOptions(upsert: true),
            );

        if (upload.isEmpty) {
          throw Exception("Image upload failed");
        }

        finalImageUrl = supabase.storage
            .from('profile_photo')
            .getPublicUrl(fileName);
      }

      /// UPDATE DB
      final response = await supabase.from('tbl_user').update({
        'user_name': nameController.text,
        'user_contact': contactController.text,
        'user_address': addressController.text,
        'user_photo': finalImageUrl,
      }).eq('user_id', user!.id);

      debugPrint("Update Response: $response");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Updated Successfully")),
      );

      loadProfile();
    } catch (e) {
      debugPrint("Update Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    /// PROFILE IMAGE
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: imageBytes != null
                            ? MemoryImage(imageBytes!)
                            : (imageUrl != null && imageUrl!.isNotEmpty)
                                ? NetworkImage(imageUrl!)
                                : null,
                        child: (imageBytes == null &&
                                (imageUrl == null || imageUrl!.isEmpty))
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildField("Name", Icons.person, nameController),
                  
                    _buildField("Contact", Icons.call, contactController),
                    _buildField("Address", Icons.home, addressController),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: UpdateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Update",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
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

  Widget _buildField(
      String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          filled: true,
          fillColor: const Color(0xFFF7F7F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
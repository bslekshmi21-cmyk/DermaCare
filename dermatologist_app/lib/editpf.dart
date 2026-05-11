import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Editpf extends StatefulWidget {
  const Editpf({super.key});

  @override
  State<Editpf> createState() => _EditpfState();
}

class _EditpfState extends State<Editpf> {
  final supabase = Supabase.instance.client;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();

  Uint8List? imageBytes;
  PlatformFile? pickedImage;

  String? imageUrl;

  /// PICK IMAGE
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
  Future<void> fetchProfile() async {
    try {
      final dermo = supabase.auth.currentUser;

      final response = await supabase
          .from('tbl_dermatologist')
          .select()
          .eq('dermatologist_id', dermo!.id)
          .single();

      setState(() {
        nameController.text = response['dermatologist_name'] ?? "";
        contactController.text = response['dermatologist_contact'] ?? "";
        experienceController.text =
            response['dermatologist_experience'] ?? "";
        imageUrl = response['dermatologist_photo'];
      });
    } catch (e) {
      debugPrint("Load Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  /// UPDATE PROFILE
  Future<void> updateProfile() async {
    try {
      final user = supabase.auth.currentUser;

      String? finalImageUrl = imageUrl;

      if (imageBytes != null) {
        final fileName =
            "profile_${DateTime.now().millisecondsSinceEpoch}.jpg";

        await supabase.storage
            .from('dermoprofile_photo')
            .uploadBinary(
              fileName,
              imageBytes!,
              fileOptions: const FileOptions(upsert: true),
            );

        finalImageUrl = supabase.storage
            .from('dermoprofile_photo')
            .getPublicUrl(fileName);
      }

      await supabase.from('tbl_dermatologist').update({
        'dermatologist_name': nameController.text,
        'dermatologist_contact': contactController.text,
        'dermatologist_experience': experienceController.text,
        'dermatologist_photo': finalImageUrl,
      }).eq('dermatologist_id', user!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Updated Successfully"),
          backgroundColor: Color(0xFF0A6C74),
        ),
      );

      fetchProfile();
    } catch (e) {
      debugPrint("Update Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// FIELD UI (MATCH PROFILE STYLE)
  Widget _buildField(
      String label, IconData icon, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(14),
      ),

      child: TextFormField(
        controller: controller,

        decoration: InputDecoration(
          labelText: label,

          prefixIcon: Icon(
            icon,
            color: const Color(0xFF0A6C74),
          ),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
        ),
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

        iconTheme: const IconThemeData(
          color: Color(0xFF0A6C74),
        ),

        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Color(0xFF0A6C74),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
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
                /// PROFILE IMAGE (MATCH PROFILE PAGE)
                GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
  radius: 55,
  backgroundColor: const Color(0xFF0A6C74),

  backgroundImage: imageBytes != null
      ? MemoryImage(imageBytes!)
      : (imageUrl != null && imageUrl!.isNotEmpty)
          ? NetworkImage(imageUrl!)
          : null,

  child: (imageBytes == null &&
          (imageUrl == null || imageUrl!.isEmpty))
      ? const Icon(
          Icons.person,
          size: 55,
          color: Colors.white,
        )
      : null,
),
                ),

                const SizedBox(height: 25),

                _buildField("Name", Icons.person, nameController),
                _buildField("Contact", Icons.phone, contactController),
                _buildField("Experience", Icons.work, experienceController),

                const SizedBox(height: 25),

                /// UPDATE BUTTON (MATCH PROFILE STYLE)
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    onPressed: updateProfile,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A6C74),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      "Update Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
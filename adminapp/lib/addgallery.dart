import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:supabase_flutter/supabase_flutter.dart';

class Addgallery extends StatefulWidget {
  final int pid;

  const Addgallery({super.key, required this.pid});

  @override
  State<Addgallery> createState() => _AddgalleryState();
}

class _AddgalleryState extends State<Addgallery> {
  file_picker.PlatformFile? pickedImage;
  Uint8List? imageBytes;
  bool isLoading = false;
  List<Map<String, dynamic>> galleryList = [];

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchGallery();
  }

  Future<void> fetchGallery() async {
    try {
      final response = await supabase
          .from('tbl_gallery')
          .select()
          .eq('product_id', widget.pid);

      setState(() {
        galleryList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
  }

  Future<void> handleImagePick() async {
    final result = await file_picker.FilePicker.pickFiles(
      type: file_picker.FileType.image,
      withData: true,
    );

    if (result == null) return;

    setState(() {
      pickedImage = result.files.first;
      imageBytes = pickedImage!.bytes;
    });
  }

  Future<String?> photoUpload(String uid) async {
    if (imageBytes == null || pickedImage == null) return null;

    final ext = pickedImage!.extension ?? 'jpg';
    final filePath = "gallery/$uid.$ext";

    await supabase.storage.from('product_photo').uploadBinary(
          filePath,
          imageBytes!,
          fileOptions: FileOptions(upsert: true),
        );

    return supabase.storage.from('product_photo').getPublicUrl(filePath);
  }

  Future<void> addGallery() async {
    if (imageBytes == null) {
      _showSnackBar("Please select image", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    final imageUrl = await photoUpload(uid);

    if (imageUrl != null) {
      await supabase.from('tbl_gallery').insert({
        'gallery_files': imageUrl,
        'product_id': widget.pid,
      });

      setState(() {
        imageBytes = null;
        pickedImage = null;
      });

      fetchGallery();
    }

    setState(() => isLoading = false);
  }

  Future<void> deleteItem(int id) async {
    await supabase.from('tbl_gallery').delete().eq('gallery_id', id);
    fetchGallery();
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Gallery Management"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

     
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Product Gallery",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// UPLOAD CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [

                    GestureDetector(
                      onTap: handleImagePick,
                      child: Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                          image: imageBytes != null
                              ? DecorationImage(
                                  image: MemoryImage(imageBytes!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: imageBytes == null
                            ? const Icon(Icons.upload)
                            : null,
                      ),
                    ),

                    const SizedBox(width: 20),

                    ElevatedButton(
                      onPressed: isLoading ? null : addGallery,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A0A5A),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Upload",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Uploaded Images",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: galleryList.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final item = galleryList[index];

                  return Stack(
                    children: [

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item['gallery_files'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),

                      Positioned(
                        right: 5,
                        top: 5,
                        child: GestureDetector(
                          onTap: () => deleteItem(item['gallery_id']),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
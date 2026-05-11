import 'package:adminapp/main.dart';
import 'package:flutter/material.dart';

class Dermolist extends StatefulWidget {
  const Dermolist({super.key});

  @override
  State<Dermolist> createState() => _DermolistState();
}

class _DermolistState extends State<Dermolist> {
  List<Map<String, dynamic>> dermolist = [];

  @override
  void initState() {
    super.initState();
    fetchDermolists();
  }

  Future<void> fetchDermolists() async {
    try {
      final response =
          await supabase.from('tbl_dermatologist').select();

      setState(() {
        dermolist = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
  }

  Future<void> updateUserStatus(dynamic uid, String status) async {
    try {
      await supabase
          .from('tbl_dermatologist')
          .update({'dermatologist_status': status})
          .eq('dermatologist_id', uid);

      fetchDermolists();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status updated to $status")),
        );
      }
    } catch (e) {
      debugPrint("Status Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Dermatologist Management"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Manage Dermatologists",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: dermolist.isEmpty
                  ? const Center(child: Text("No dermatologists found"))
                  : ListView.builder(
                      itemCount: dermolist.length,
                      itemBuilder: (context, index) {
                        final doc = dermolist[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Colors.grey.shade300),
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// TOP SECTION
                              Row(
                                children: [

                                  /// PROFILE IMAGE
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage: (doc[
                                                    'dermatologist_photo'] !=
                                                null &&
                                            doc['dermatologist_photo']
                                                .toString()
                                                .isNotEmpty)
                                        ? NetworkImage(
                                            doc['dermatologist_photo'])
                                        : null,
                                    child: (doc['dermatologist_photo'] ==
                                                null ||
                                            doc['dermatologist_photo']
                                                .toString()
                                                .isEmpty)
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),

                                  const SizedBox(width: 12),

                                  /// INFO
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doc['dermatologist_name'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          doc['dermatologist_email'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                        Text(
                                          "Experience: ${doc['dermatologist_experience'] ?? ''} yrs",
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                        Text(
                                          "Status: ${doc['dermatologist_status'] ?? 'pending'}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              /// PROOF IMAGE (FIXED)
                              if (doc['dermatologist_proof'] != null &&
                                  doc['dermatologist_proof']
                                      .toString()
                                      .isNotEmpty)
                                Container(
                                  height: 160,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      doc['dermatologist_proof'],
                                      fit: BoxFit.contain, // 👈 IMPORTANT FIX
                                      loadingBuilder:
                                          (context, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(
                                          child:
                                              CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 10),

                              /// ACTION BUTTONS
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [

                                  IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: () => updateUserStatus(
                                        doc['dermatologist_id'],
                                        'active'),
                                  ),

                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () => updateUserStatus(
                                        doc['dermatologist_id'],
                                        'inactive'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
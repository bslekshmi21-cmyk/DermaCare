import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:userapp/appoinment%20.dart';
import 'package:userapp/doctorinfo.dart';

class Doctorpage extends StatefulWidget {
  const Doctorpage({super.key});

  @override
  State<Doctorpage> createState() => _DoctorpageState();
}

class _DoctorpageState extends State<Doctorpage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> docList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchdoc();
  }

  Future<void> fetchdoc() async {
    try {
      final response = await supabase.from('tbl_dermatologist').select();

      docList = List<Map<String, dynamic>>.from(response);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        title: const Text("Doctors"),
        backgroundColor: const Color(0xFFF4F7FB),
        foregroundColor: const Color(0xFF0A6C74),
        elevation: 0,
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "All Doctors",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A6C74),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      itemCount: docList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),

                      itemBuilder: (context, index) {
                        final doc = docList[index];

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// IMAGE
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),

                                  child:
                                      (doc['dermatologist_photo'] != null &&
                                          doc['dermatologist_photo']
                                              .toString()
                                              .isNotEmpty)
                                      ? Image.network(
                                          doc['dermatologist_photo'],
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/docc1.png',
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),

                              /// INFO
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doc['dermatologist_name'] ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF0A6C74),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      "${doc['dermatologist_experience'] ?? 0} yrs experience",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    /// BOOK NOW BUTTON
                                    SizedBox(
                                      width: double.infinity,
                                      height: 32,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF0A6C74,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),

                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Appoinment(
                                                doc['dermatologist_id']
                                                    .toString(),
                                              ),
                                            ),
                                          );
                                        },

                                        child: const Text(
                                          "Book Now",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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

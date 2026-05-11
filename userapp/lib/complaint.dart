import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Complaint extends StatefulWidget {
  const Complaint({super.key});

  @override
  State<Complaint> createState() =>
      _ComplaintState();
}

class _ComplaintState extends State<Complaint> {
  final TextEditingController titleController =
      TextEditingController();
  final TextEditingController contentController =
      TextEditingController();

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;

  final Color primaryColor =
      const Color(0xFF0A0A5A);

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> fetchComplaints() async {
    try {
      final user = supabase.auth.currentUser;

      final response = await supabase
          .from('tbl_complaint')
          .select('*')
          .eq('user_id', user!.id)
          .order('complaint_id', ascending: false);

      setState(() {
        complaints =
            List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> insertData() async {
    try {
      if (titleController.text.trim().isEmpty ||
          contentController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill all fields"),
          ),
        );
        return;
      }

      final user = supabase.auth.currentUser;

      await supabase.from('tbl_complaint').insert({
        'complaint_title':
            titleController.text.trim(),
        'complaint_content':
            contentController.text.trim(),
        'complaint_date':
            DateTime.now().toIso8601String(),
        'complaint_status': 'pending',
        'complaint_reply': null,
        'user_id': user?.id,
      });

      titleController.clear();
      contentController.clear();

      fetchComplaints();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complaint Submitted"),
        ),
      );
    } catch (e) {
      debugPrint("Insert Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("My Complaints"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            /// INPUT FORM CARD
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),

              child: Column(
                children: [

                  TextField(
                    controller: titleController,
                    decoration:
                        const InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: contentController,
                    maxLines: 4,
                    decoration:
                        const InputDecoration(
                      labelText: "Content",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryColor,
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                      ),
                      onPressed: insertData,
                      child: const Text(
                        "Submit Complaint",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST
            Expanded(
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : complaints.isEmpty
                      ? const Center(
                          child: Text(
                            "No complaints found",
                          ),
                        )
                      : ListView.builder(
                          itemCount:
                              complaints.length,
                          itemBuilder:
                              (context, index) {
                            final item =
                                complaints[index];

                            final bool isReplied =
                                item['complaint_status'] ==
                                    'replied';

                            return Container(
                              margin:
                                  const EdgeInsets.only(
                                      bottom: 15),
                              padding:
                                  const EdgeInsets.all(
                                      15),

                              decoration:
                                  BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            12),
                                border: Border.all(
                                  color: Colors
                                      .grey.shade300,
                                ),
                              ),

                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [

                                  /// TITLE
                                  Text(
                                    item['complaint_title'] ??
                                        '',
                                    style:
                                        const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 5),

                                  /// CONTENT
                                  Text(item[
                                          'complaint_content'] ??
                                      ''),

                                  const SizedBox(
                                      height: 10),

                                  /// STATUS
                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color: isReplied
                                          ? Colors.green
                                              .withOpacity(
                                                  0.2)
                                          : Colors
                                              .orange
                                              .withOpacity(
                                                  0.2),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  20),
                                    ),
                                    child: Text(
                                      isReplied
                                          ? "Replied"
                                          : "Pending",
                                      style: TextStyle(
                                        color: isReplied
                                            ? Colors
                                                .green
                                            : Colors
                                                .orange,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height: 10),

                                  /// ADMIN REPLY
                                  if (isReplied &&
                                      item['complaint_reply'] !=
                                          null)
                                    Container(
                                      width:
                                          double.infinity,
                                      padding:
                                          const EdgeInsets
                                              .all(
                                                  12),
                                      decoration:
                                          BoxDecoration(
                                        color: Colors
                                            .green
                                            .withOpacity(
                                                0.1),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                                    10),
                                        border:
                                            Border.all(
                                          color:
                                              Colors.green,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          const Text(
                                            "Admin Reply",
                                            style:
                                                TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color: Colors
                                                  .green,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: 5),
                                          Text(item[
                                              'complaint_reply']),
                                        ],
                                      ),
                                    )
                                  else
                                    const Text(
                                      "Waiting for admin reply...",
                                      style: TextStyle(
                                        color:
                                            Colors.orange,
                                        fontStyle:
                                            FontStyle
                                                .italic,
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
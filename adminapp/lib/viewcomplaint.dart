import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class Viewcomplaint extends StatefulWidget {
  const Viewcomplaint({super.key});

  @override
  State<Viewcomplaint> createState() =>
      _ViewcomplaintState();
}

class _ViewcomplaintState extends State<Viewcomplaint> {
  List<Map<String, dynamic>> complaints = [];
  bool isLoading = true;

  final Color primaryColor =
      const Color(0xFF0A0A5A);

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  Future<void> fetchComplaints() async {
    try {
      final response = await Supabase.instance.client
          .from('tbl_complaint')
          .select('*, tbl_user(user_name, user_email)')
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

  String formatDate(String? date) {
    if (date == null || date.isEmpty) return '';
    try {
      return DateFormat('dd-MM-yyyy')
          .format(DateTime.parse(date));
    } catch (e) {
      return date;
    }
  }

  void _showReplyDialog(int complaintId) {
    final TextEditingController controller =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reply Complaint"),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Enter reply...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await submitReply(
                  complaintId,
                  controller.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text(
              "Submit",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submitReply(
    int id,
    String reply,
  ) async {
    try {
      await Supabase.instance.client
          .from('tbl_complaint')
          .update({
            'complaint_reply': reply,
            'complaint_status': 'replied',
          })
          .eq('complaint_id', id);

      fetchComplaints();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reply sent successfully"),
        ),
      );
    } catch (e) {
      debugPrint("Reply Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("View Complaints"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : complaints.isEmpty
              ? const Center(
                  child: Text("No complaints found"),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: complaints.length,

                  itemBuilder: (context, index) {
                    final item = complaints[index];
                    final user = item['tbl_user'];

                    final bool isReplied =
                        item['complaint_status'] ==
                            'replied';

                    return Container(
                      margin: const EdgeInsets.only(
                          bottom: 15),
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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          /// USER INFO
                          Text(
                            user?['user_name'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          Text(
                            user?['user_email'] ?? '',
                            style: TextStyle(
                              color:
                                  Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),

                          const Divider(),

                          /// TITLE
                          Text(
                            item['complaint_title'] ??
                                '',
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 5),

                          /// CONTENT
                          Text(
                            item['complaint_content'] ??
                                '',
                          ),

                          const SizedBox(height: 10),

                          /// DATE + STATUS
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [

                              Text(
                                "Date: ${formatDate(item['complaint_date'])}",
                                style: TextStyle(
                                  color: Colors
                                      .grey.shade600,
                                  fontSize: 12,
                                ),
                              ),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),

                                decoration: BoxDecoration(
                                  color: isReplied
                                      ? Colors.green
                                          .withOpacity(
                                              0.2)
                                      : Colors.orange
                                          .withOpacity(
                                              0.2),
                                  borderRadius:
                                      BorderRadius
                                          .circular(20),
                                ),

                                child: Text(
                                  isReplied
                                      ? "Replied"
                                      : "Pending",
                                  style: TextStyle(
                                    color: isReplied
                                        ? Colors.green
                                        : Colors
                                            .orange,
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          /// BUTTON OR STATUS
                          if (!isReplied)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                      primaryColor,
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    vertical: 12,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      10,
                                    ),
                                  ),
                                ),

                                onPressed: () {
                                  _showReplyDialog(
                                    item['complaint_id'],
                                  );
                                },

                                icon: const Icon(
                                  Icons.reply,
                                  color: Colors.white,
                                ),

                                label: const Text(
                                  "Reply",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.all(
                                      12),
                              decoration: BoxDecoration(
                                color: Colors.green
                                    .withOpacity(0.1),
                                borderRadius:
                                    BorderRadius
                                        .circular(10),
                                border: Border.all(
                                  color: Colors.green,
                                ),
                              ),
                              child: const Text(
                                "Already Replied",
                                textAlign:
                                    TextAlign.center,
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
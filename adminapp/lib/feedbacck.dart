import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AdminFeedbackPage extends StatefulWidget {
  const AdminFeedbackPage({super.key});

  @override
  State<AdminFeedbackPage> createState() =>
      _AdminFeedbackPageState();
}

class _AdminFeedbackPageState
    extends State<AdminFeedbackPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> feedbackList = [];
  bool isLoading = true;

  final Color primaryColor =
      const Color(0xFF0A0A5A);

  @override
  void initState() {
    super.initState();
    fetchFeedback();
  }

  Future<void> fetchFeedback() async {
    try {
      final response = await supabase
          .from('tbl_feedback')
          .select('''
            *,
            tbl_user (
              user_name,
              user_email
            )
          ''')
          .order('feedback_id', ascending: false);

      setState(() {
        feedbackList =
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("User Feedbacks"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : feedbackList.isEmpty
              ? const Center(
                  child: Text(
                    "No feedback available",
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: feedbackList.length,

                  itemBuilder: (context, index) {
                    final item = feedbackList[index];
                    final user = item['tbl_user'];

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
                            user?['user_name'] ??
                                'Unknown User',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          Text(
                            user?['user_email'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),

                          const Divider(),

                          /// FEEDBACK TEXT
                          Text(
                            item['feedback_content'] ??
                                '',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// DATE + RATING
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [

                              Text(
                                formatDate(item[
                                    'feedback_date']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors
                                      .grey.shade600,
                                ),
                              ),

                              if (item['rating'] !=
                                  null)
                                Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: Colors
                                        .amber
                                        .withOpacity(
                                            0.2),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                20),
                                  ),
                                  child: Text(
                                    "⭐ ${item['rating']}",
                                    style: const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
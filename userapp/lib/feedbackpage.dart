import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() =>
      _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController feedbackController =
      TextEditingController();

  final supabase = Supabase.instance.client;

  final Color primaryColor =
      const Color(0xFF0A0A5A);

  bool isLoading = false;

  int selectedRating = 0;

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  void setRating(int rating) {
    setState(() {
      selectedRating = rating;
    });
  }

  Future<void> submitFeedback() async {
    final text = feedbackController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter feedback"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = supabase.auth.currentUser;

      await supabase.from('tbl_feedback').insert({
        'feedback_content': text,
        'feedback_date':
            DateTime.now().toIso8601String(),
        'user_id': user?.id,
        'rating': selectedRating, // ⭐ ADDED
      });

      feedbackController.clear();
      selectedRating = 0;

      setState(() {
        isLoading = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text("Thank You ❤️"),
          content: const Text(
            "We really appreciate your feedback!",
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget buildStar(int index) {
    return IconButton(
      onPressed: () => setRating(index),
      icon: Icon(
        Icons.star,
        size: 32,
        color: index <= selectedRating
            ? Colors.amber
            : Colors.grey.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Feedback"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            /// HEADER
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

              child: Row(
                children: [
                  Icon(
                    Icons.feedback,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Share Your Feedback",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ⭐ RATING
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rate your experience",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: List.generate(
                      5,
                      (index) => buildStar(
                        index + 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// FEEDBACK TEXT
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

              child: TextField(
                controller: feedbackController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText:
                      "Write your feedback...",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// SUBMIT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
                onPressed:
                    isLoading ? null : submitFeedback,
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Submit Feedback",
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
    );
  }
}
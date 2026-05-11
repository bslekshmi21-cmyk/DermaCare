import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyAppointments extends StatefulWidget {
  const MyAppointments({super.key});

  @override
  State<MyAppointments> createState() => _MyAppointmentsState();
}

class _MyAppointmentsState extends State<MyAppointments> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

  static const Color primary = Color(0xFF2D6A6F);

  @override
  void initState() {
    super.initState();
    getAppointments();
  }

  // Logic to clean the Date string (Removes the T00:00:00 part)
  String formatMyDate(String? date) {
    if (date == null) return "";
    return date.split('T')[0]; 
  }

  // Logic to convert 24h string to 12h format with AM/PM
  String formatMyTime(String? time) {
    if (time == null || time.isEmpty) return "";
    
    try {
      List<String> parts = time.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        
        String period = hour >= 12 ? "PM" : "AM";
        
        // Convert hour to 12-hour format
        hour = hour % 12;
        if (hour == 0) hour = 12; 

        // Ensure minutes always show two digits (e.g., 05 instead of 5)
        String minuteStr = minute < 10 ? "0$minute" : "$minute";
        
        return "$hour:$minuteStr $period";
      }
    } catch (e) {
      return time; // Return raw time if parsing fails
    }
    return time;
  }

  Future<void> getAppointments() async {
    try {
      final data = await supabase
          .from('tbl_appoinment')
          .select('''
        *,
        tbl_user(user_name,user_photo),
        tbl_dermatologist(dermatologist_name,dermatologist_photo)
      ''')
          .eq('dermatologist_id', supabase.auth.currentUser!.id);

      setState(() {
        appointments = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Fetch error: $e");
    }
  }

  Future<void> updateStatus(int id, String status) async {
    try {
      await supabase
          .from('tbl_appoinment')
          .update({'appoinment_status': status})
          .eq('appoinment_id', id);

      await getAppointments();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Appointment $status"),
          backgroundColor: status == "Accepted" ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("My Appointments"),
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? const Center(child: Text("No Appointments"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final item = appointments[index];

                    final user = item['tbl_user'] ?? {};
                    final doctor = item['tbl_dermatologist'] ?? {};

                    final userPhoto = user['user_photo'] ?? "";
                    final status = item['appoinment_status'] ?? "";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TOP ROW
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundImage: userPhoto.isNotEmpty
                                    ? NetworkImage(userPhoto)
                                    : null,
                                child: userPhoto.isEmpty
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['user_name'] ?? "Unknown User",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      doctor['dermatologist_name'] ??
                                          "Unknown Doctor",
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),

                              /// STATUS
                              if (status != "Pending")
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: status == "Accepted"
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: status == "Accepted"
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          /// DATE & TIME
                          Text("Date : ${formatMyDate(item['appoinment_date'])}"),
                          const SizedBox(height: 5),
                          Text("Time : ${formatMyTime(item['appoinment_time'])}"),

                          const SizedBox(height: 20),

                          /// ACTION BUTTONS (ONLY PENDING)
                          if (status == "Pending")
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                /// ACCEPT
                                SizedBox(
                                  width: 120,
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      updateStatus(
                                        item['appoinment_id'],
                                        "Accepted",
                                      );
                                    },
                                    child: const Text(
                                      "Accept",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),

                                /// REJECT
                                SizedBox(
                                  width: 120,
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      updateStatus(
                                        item['appoinment_id'],
                                        "Rejected",
                                      );
                                    },
                                    child: const Text(
                                      "Reject",
                                      style: TextStyle(color: Colors.white),
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
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Myappoinment extends StatefulWidget {
  const Myappoinment({super.key});

  @override
  State<Myappoinment> createState() => _MyappoinmentState();
}

class _MyappoinmentState extends State<Myappoinment> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  /// ✅ Logic to clean the Date string (Removes the T00:00:00 part)
  String formatMyDate(String? date) {
    if (date == null || date.isEmpty) return "N/A";
    return date.split('T')[0]; 
  }

  /// ✅ Logic to convert 24h string to 12h format with AM/PM
  String formatMyTime(String? time) {
    if (time == null || time.isEmpty) return "N/A";
    
    try {
      List<String> parts = time.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        
        // Determine AM or PM
        String period = hour >= 12 ? "PM" : "AM";
        
        // Convert to 12-hour format
        int displayHour = hour % 12;
        if (displayHour == 0) displayHour = 12; 

        // Add leading zero to minutes if needed
        String minuteStr = minute < 10 ? "0$minute" : "$minute";
        
        return "$displayHour:$minuteStr $period";
      }
    } catch (e) {
      return time; // Fallback to raw string if error
    }
    return time;
  }

  /// ✅ FETCH USER APPOINTMENTS
  Future<void> fetchAppointments() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      final data = await supabase.from('tbl_appoinment').select('''
        *,
        tbl_dermatologist(dermatologist_name,dermatologist_photo)
      ''').eq('user_id', userId);

      setState(() {
        appointments = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Fetch error: $e");
    }
  }

  /// ✅ STATUS COLOR
  Color getStatusColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("My Appointments"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? const Center(
                  child: Text("No Appointments Found"),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final item = appointments[index];

                    final doctor = item['tbl_dermatologist'] ?? {};
                    final status = item['appoinment_status'] ?? "Pending";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// DOCTOR INFO
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundImage:
                                    doctor['dermatologist_photo'] != null
                                        ? NetworkImage(
                                            doctor['dermatologist_photo'],
                                          )
                                        : null,
                                child: doctor['dermatologist_photo'] == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  doctor['dermatologist_name'] ??
                                      "Unknown Doctor",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              /// STATUS
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: getStatusColor(status)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          /// DATE (FIXED)
                          Text(
                            "Date: ${formatMyDate(item['appoinment_date'])}",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),

                          const SizedBox(height: 5),

                          /// TIME (FIXED WITH AM/PM)
                          Text(
                            "Time: ${formatMyTime(item['appoinment_time'])}",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),

                          const SizedBox(height: 10),

                          /// STATUS MESSAGE
                          if (status == "Pending")
                            const Text(
                              "Waiting for doctor response...",
                              style: TextStyle(
                                color: Colors.orange,
                              ),
                            )
                          else if (status == "Accepted")
                            const Text(
                              "Appointment Accepted ✔",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else if (status == "Rejected")
                            const Text(
                              "Appointment Rejected ❌",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
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
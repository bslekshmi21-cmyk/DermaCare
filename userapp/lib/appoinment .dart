import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:userapp/editprof.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Appoinment extends StatefulWidget {
  final String dermatologistId;

  const Appoinment(
    this.dermatologistId, {
    super.key,
  });

  @override
  State<Appoinment> createState() => _AppoinmentState();
}

class _AppoinmentState extends State<Appoinment> {
  final supabase = Supabase.instance.client;

  String photo = "";
  String doctorName = "";
  String doctorexp = "";

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  static const Color primary = Color(0xFF2D6A6F);

  Future<void> fetchAppoin() async {
    try {
      final response = await supabase
          .from('tbl_dermatologist')
          .select()
          .eq('dermatologist_id', widget.dermatologistId)
          .single();

      setState(() {
        photo = response['dermatologist_photo'] ?? "";
        doctorName = response['dermatologist_name'] ?? "";
        doctorexp = response['dermatologist_experience'].toString();
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  /// ✅ FINAL BOOKING FUNCTION
  Future<void> bookAppointment() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      if (selectedDate == null || selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select date and time")),
        );
        return;
      }

      await supabase.from('tbl_appoinment').insert({
        'user_id': user.id, // ✅ USER ID
        'dermatologist_id': widget.dermatologistId, // ✅ DOCTOR ID
        'appoinment_date': selectedDate!.toIso8601String(),
        'appoinment_time': "${selectedTime!.hour}:${selectedTime!.minute}",
        'appoinment_status': 'Pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Appointment Booked Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Booking Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booking Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAppoin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        title: const Text("Book Appointment"),
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            /// DOCTOR CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage:
                        photo.isNotEmpty ? NetworkImage(photo) : null,
                    child: photo.isEmpty
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("$doctorexp years experience"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Select Schedule",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            /// DATE
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(Icons.calendar_month, color: Colors.teal),
              title: Text(
                selectedDate == null
                    ? "Choose Date"
                    : selectedDate.toString().split(" ")[0],
              ),
              onTap: selectDate,
            ),

            const SizedBox(height: 10),

            /// TIME
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(Icons.access_time, color: Colors.teal),
              title: Text(
                selectedTime == null
                    ? "Choose Time"
                    : selectedTime!.format(context),
              ),
              onTap: selectTime,
            ),

            const SizedBox(height: 30),

            /// CONFIRM BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: bookAppointment,
                child: const Text(
                  "Confirm Booking",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
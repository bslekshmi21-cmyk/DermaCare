import 'package:flutter/material.dart';

class Doctordetail extends StatefulWidget {
  const Doctordetail({super.key, required this.doctordoc});

  final dynamic doctordoc;

  @override
  State<Doctordetail> createState() => _DoctordetailState();
}

class _DoctordetailState extends State<Doctordetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Doctor Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 340,
            margin: const EdgeInsets.all(16),

            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [

                    /// DOCTOR IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        widget.doctordoc['pimage'],
                        height: 500,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// NAME
                    Text(
                      widget.doctordoc['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    /// FEES CARD
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),

                     
                      child: Text(
                        " ${widget.doctordoc['fees']}",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// CATEGORY
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),

                      child: Column(
                        children: [
                          const Icon(
                            Icons.medical_services,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.doctordoc['category'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// BOOK BUTTON (optional but standard in doctor apps)
                    SizedBox(
                      width: double.infinity,
                      height: 45,

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        onPressed: () {
                          // booking action
                        },

                        child: const Text(
                          "Book Appointment",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
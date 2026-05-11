import 'package:bottom_nav_layout/bottom_nav_layout.dart';
import 'package:dermatologist_app/appoinment.dart';
import 'package:dermatologist_app/home.dart';
import 'package:flutter/material.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavLayout(
      pages: [
        (_) => const Home(),

        /// ✅ FIX: Pass required dermatologistId
        (_) => const MyAppointments()
      ],

      bottomNavigationBar: (currentIndex, onTap) {
        return BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => onTap(index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color.fromARGB(255, 46, 116, 49),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: "Appointment",
            ),
          ],
        );
      },

      savePageState: true,
      lazyLoadPages: true,

      pageStack: ReorderToFrontPageStack(
        initialPage: 0,
      ),
    );
  }
}
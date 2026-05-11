import 'package:bottom_nav_layout/bottom_nav_layout.dart';
import 'package:flutter/material.dart';

import 'package:userapp/home.dart';
import 'package:userapp/my_cart.dart';
import 'package:userapp/myappoinment.dart';
import 'package:userapp/productall.dart';
import 'package:userapp/doctorall.dart';
import 'package:userapp/myprofile.dart';
import 'package:userapp/user_homepage.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
   return BottomNavLayout(
      pages: [
        (_) => const UserHomePage(),       // Index 0
        (_) => const Productdetail(), // Index 1
        (_) => const Doctorpage(),    // Index 2
        (_) => const Myappoinment(),  // Index 3
        (_) => const Myprofile(),     // Index 4
        (_) => const MyCart(),        // Index 5 (This was likely missing or miscounted)
      ],

    bottomNavigationBar: (currentIndex, onTap) {
        return BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => onTap(index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color.fromARGB(255, 46, 116, 49),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Products"),
            BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: "Dermatologists"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Appointments"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_basket), label: "Cart"), // Index 5
          ],
        );
      },
      savePageState: true,
      lazyLoadPages: true,
      pageStack: ReorderToFrontPageStack(initialPage: 0),
    );
  }
}
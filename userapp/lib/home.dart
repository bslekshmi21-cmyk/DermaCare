import 'package:flutter/material.dart';
import 'package:userapp/docdata.dart';
import 'package:userapp/doctorall.dart';
import 'package:userapp/productdata.dart';
import 'package:userapp/productall.dart';

class welcome extends StatefulWidget {
  const welcome({super.key});

  @override
  State<welcome> createState() => _welcomeState();
}

class _welcomeState extends State<welcome> {
  final Color primary = const Color(0xFF2E7431);
  final Color bg = const Color(0xFFF2F3F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),

            /// TITLE
            Text(
              'WELCOME',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primary,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 15),

            /// TOP CARDS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  _buildTopCard("Heat Level"),
                  const SizedBox(height: 10),
                  _buildTopCard("Today's Prediction"),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// PRODUCTS HEADER
            _buildSectionHeader(
              title: "PRODUCT",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Productdetail()),
                );
              },
            ),

            /// PRODUCTS GRID
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GridView.builder(
                  itemCount: product.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final pro = product[index];

                    return _buildCard(pro['image'], pro['pname']);
                  },
                ),
              ),
            ),

            /// DOCTOR HEADER
            _buildSectionHeader(
              title: "DOCTOR",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Doctorpage()),
                );
              },
            ),

            /// DOCTOR GRID
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GridView.builder(
                  itemCount: doctor.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final doc = doctor[index];

                    return _buildCard(doc['image'], doc['pname']);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// TOP CARD
  Widget _buildTopCard(String title) {
    return Container(
      height: 90,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
      ),
    );
  }

  /// SECTION HEADER
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(Icons.arrow_circle_right_outlined, color: primary),
          )
        ],
      ),
    );
  }

  /// GRID CARD
  Widget _buildCard(String image, String name) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:adminapp/addgallery.dart';
import 'package:adminapp/addpro.dart';
import 'package:adminapp/addstock.dart';
import 'package:adminapp/category.dart';
import 'package:adminapp/dermolist.dart';
import 'package:adminapp/district.dart';
import 'package:adminapp/feedbacck.dart';
import 'package:adminapp/heat.dart';
import 'package:adminapp/level.dart';
import 'package:adminapp/login.dart';
import 'package:adminapp/myproduct.dart';
import 'package:adminapp/place.dart';
import 'package:adminapp/shipping.dart';
import 'package:adminapp/subcate.dart';
import 'package:adminapp/type.dart';
import 'package:adminapp/userlist.dart';
import 'package:adminapp/viewcomplaint.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class dash extends StatefulWidget {
  const dash({super.key});

  @override
  State<dash> createState() => _dashState();
}

class _dashState extends State<dash> {
  Future<void> logout(BuildContext context) async {
    try {
      // 1. Sign out from Supabase
      await Supabase.instance.client.auth.signOut();

      // 2. Check if the widget is still in the tree
      if (!context.mounted) return;

      // 3. Clear navigation and go to Login
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false, // This removes all previous screens from the stack
      );
    } catch (e) {
      // Show an error if something goes wrong
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error logging out: $e")));
      }
    }
  }

  Widget menuItem(
    IconData icon,
    String title, {
    Widget? page,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      onTap: () {
        if (onTap != null) {
          onTap(); // Execute custom logic (Logout)
        } else if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
    );
  }

  Widget statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      /// APPBAR
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 10),
          Icon(Icons.person_outline),
          SizedBox(width: 10),
        ],
      ),

      body: Row(
        children: [
          /// SIDEBAR
          Container(
            width: 250,
            color: Colors.white,
            child: ListView(
              children: [
                const DrawerHeader(
                  child: Text(
                    "ADMIN PANEL",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                menuItem(Icons.home, "Dashboard", page: const dash()),
                menuItem(Icons.location_city, "District", page: distr()),
                menuItem(Icons.category, "Category", page: cate()),
                menuItem(Icons.place, "Place", page: Place()),
                menuItem(Icons.list, "Subcategory", page: Subcate()),
                menuItem(Icons.add_box, "Add Product", page: Addpro()),
                menuItem(Icons.shopping_bag, "My Product", page: Myproduct()),
                menuItem(Icons.people, "Users", page: UserList()),
                menuItem(
                  Icons.medical_services,
                  "Dermatologist",
                  page: Dermolist(),
                ),
                menuItem(Icons.tune, "Skin Type", page: TypePage()),
                menuItem(
                  Icons.local_fire_department,
                  "Heat Absorption",
                  page: Heat(),
                ),
                menuItem(Icons.layers, "Level", page: Level()),
                menuItem(Icons.report, "View Complaint", page: Viewcomplaint()),
                menuItem(
                  Icons.local_shipping,
                  "Track Product",
                  page: OrderDispatcherPage(),
                ),
                menuItem(Icons.feedback, "Feedback", page: AdminFeedbackPage()),
                menuItem(
                  Icons.logout,
                  "Logout",
                  onTap: () =>
                      logout(context), // Correctly calling the function
                ),
              ],
            ),
          ),

          /// MAIN CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    const Text(
                      "Overview",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// STATS
                    Row(
                      children: [
                        statCard(
                          "Total Sales",
                          "\$25,000",
                          Icons.shopping_cart,
                          Colors.blue,
                        ),
                        const SizedBox(width: 15),
                        statCard(
                          "Purchases",
                          "\$18,000",
                          Icons.swap_horiz,
                          Colors.green,
                        ),
                        const SizedBox(width: 15),
                        statCard(
                          "Expenses",
                          "\$9,000",
                          Icons.currency_exchange,
                          Colors.purple,
                        ),
                        const SizedBox(width: 15),
                        statCard(
                          "Invoices",
                          "\$25,000",
                          Icons.receipt_long,
                          Colors.orange,
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// CHART SECTION
                    Row(
                      children: [
                        /// BAR CHART
                        Expanded(
                          child: Container(
                            height: 280,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Image.asset('assets/barr.jpeg'),
                          ),
                        ),

                        const SizedBox(width: 20),

                        /// OVERVIEW
                        Expanded(
                          child: Container(
                            height: 280,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "5.5k",
                                      style: TextStyle(fontSize: 26),
                                    ),
                                    Text(
                                      "First Time",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      "3.5k",
                                      style: TextStyle(fontSize: 26),
                                    ),
                                    Text(
                                      "Returning",
                                      style: TextStyle(color: Colors.orange),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    /// STORAGE CARD
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              "Your storage is almost full. Upgrade now to get more space.",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text("Upgrade"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

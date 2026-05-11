import 'package:flutter/material.dart';

import 'package:userapp/editprof.dart';
import 'package:userapp/my_cart.dart';

class Productd extends StatefulWidget {
  const Productd({super.key, required this.productp});

  final dynamic productp;

  @override
  State<Productd> createState() => _ProductdState();
}

class _ProductdState extends State<Productd> {
  Future<void> _addToCart(BuildContext context, int pid) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Check for an active booking
      final booking = await supabase
          .from('tbl_booking')
          .select()
          .eq('user_id', user.id)
          .eq('booking_status', 0)
          .maybeSingle();

      int? bookingId; // Change to nullable int to safely handle the transition

      if (booking != null) {
        bookingId = booking['booking_id'];

        // Check if product already exists in this booking
        final existing = await supabase
            .from('tbl_cart')
            .select()
            .eq(
              'booking_id',
              bookingId as Object,
            ) // Cast to Object to ensure compatibility
            .eq('product_id', pid)
            .maybeSingle();

        if (existing != null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Already in cart"),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      } else {
        // 2. Create a new booking if none exists
        final nb = await supabase
            .from('tbl_booking')
            .insert({
              'user_id': user.id,
              'booking_status': 0,
              'booking_amount': 0,
            })
            .select('booking_id') // Explicitly select the ID
            .single();

        bookingId = nb['booking_id'];
      }

      // Double check that we actually have a bookingId before inserting to cart
      if (bookingId == null) {
        throw Exception("Failed to retrieve Booking ID");
      }

      // 3. Insert into cart
      await supabase.from('tbl_cart').insert({
        'booking_id': bookingId,
        'product_id': pid,
        'cart_quantity': 1,
        'cart_status': 0,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Added to cart ✓"),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => MyCart(),));
      }
    } catch (e) {
      debugPrint("Cart error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error adding to cart: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List gallery = widget.productp['gallery_files'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              /// TITLE
              const Text(
                "Product Information",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              /// MAIN CARD
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      /// IMAGE GALLERY
                      SizedBox(
                        height: 260,

                        child: gallery.isNotEmpty
                            ? ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: gallery.length,

                                itemBuilder: (context, index) {
                                  final image = gallery[index];

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),

                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),

                                      child: Image.network(
                                        image,
                                        width: 260,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),

                                child: const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 90,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(height: 15),

                      /// PRODUCT NAME
                      Text(
                        widget.productp['product_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7431),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// PRICE BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),

                        child: Text(
                          "₹${widget.productp['product_price'] ?? '0'}",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// DESCRIPTION
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        widget.productp['product_description'] ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// INFO CARDS
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              Icons.local_fire_department,
                              Colors.orange,
                              widget.productp['tbl_heat']?['heat_name'] ??
                                  'No Heat',
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: _buildInfoCard(
                              Icons.category,
                              Colors.green,
                              widget.productp['tbl_category']?['category_name'] ??
                                  'Category',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// ADD TO CART BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 48,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                          onPressed: () {
                            // Use widget.productp instead of product
                            final int pid = widget.productp['product_id'] is int
                                ? widget.productp['product_id']
                                : int.parse(
                                    widget.productp['product_id'].toString(),
                                  );

                            _addToCart(context, pid);
                          },

                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                color: const Color.fromARGB(255, 25, 126, 136),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "ADD TO CART",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(
                                    255,
                                    25,
                                    126,
                                    136,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// INFO CARD WIDGET
  Widget _buildInfoCard(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

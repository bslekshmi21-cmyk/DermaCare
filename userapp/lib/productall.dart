/// PRODUCT LIST PAGE

import 'package:flutter/material.dart';

import 'package:userapp/main.dart';
import 'package:userapp/my_cart.dart';
import 'package:userapp/productinfo.dart';

class Productdetail extends StatefulWidget {
  const Productdetail({super.key});

  @override
  State<Productdetail> createState() => _ProductdetailState();
}

class _ProductdetailState extends State<Productdetail> {
  List<Map<String, dynamic>> photoList = [];
  bool _isLoading = true;

  final Color primary = const Color(0xFF2E7431);

  @override
  void initState() {
    super.initState();
    fetchPhoto();
  }

  Future<void> fetchPhoto() async {
    try {
      final photo = await supabase.from('tbl_product').select('''
            *,
            tbl_category(category_name),
            tbl_type(type_name),
            tbl_level(level_name),
            tbl_heat(heat_name),
            tbl_gallery(gallery_files)
          ''');

      photoList = List<Map<String, dynamic>>.from(photo);

      for (var product in photoList) {
        product['gallery_files'] = (product['tbl_gallery'] as List)
            .map((e) => e['gallery_files'])
            .toList();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

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
          .eq('booking_id', bookingId as Object) // Cast to Object to ensure compatibility
          .eq('product_id', pid)
          .maybeSingle();

      if (existing != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Already in cart"), behavior: SnackBarBehavior.floating),
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
            'booking_amount': 0
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding to cart: $e")),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Products"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchPhoto),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "All Products",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : photoList.isEmpty
                  ? const Center(child: Text("No products found"))
                  : GridView.builder(
                      itemCount: photoList.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          ),

                      itemBuilder: (context, index) {
                        final product = photoList[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Productd(productp: product),
                              ),
                            );
                          },

                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                /// IMAGE (FULL FIXED)
                                SizedBox(
                                  height: 140,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child:
                                        product['product_photo'] != null &&
                                            product['product_photo'] != ''
                                        ? Image.network(
                                            product['product_photo'],
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: Colors.grey.shade200,
                                            child: const Center(
                                              child: Icon(Icons.image),
                                            ),
                                          ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(10),

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        product['product_name'] ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        "₹${product['product_price'] ?? '0'}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),

                                      const SizedBox(height: 5),

                                      Text(
                                        product['tbl_category']?['category_name'] ??
                                            '',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () {
                                            // FIX: Pass context and the ID
                                            final int pid =
                                                product['product_id'] is int
                                                ? product['product_id']
                                                : int.parse(
                                                    product['product_id']
                                                        .toString(),
                                                  );

                                            _addToCart(context, pid);
                                          },
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.shopping_cart_outlined,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "Add To Cart",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:userapp/editprof.dart';
import 'package:userapp/orderhistory.dart';
import 'package:userapp/payment.dart';

class MyCart extends StatefulWidget {
  const MyCart({super.key});

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  // UPDATED COLORS TO MATCH PRODUCT PAGE
  static const Color bgColor = Color(0xFFF5F6FA);
  static const Color primary = Color(0xFF2E7431);

  List cartItems = [];
  bool isLoading = true;
  bool isProcessing = false;
  double grandTotal = 0;

  @override
  void initState() {
    super.initState();
    fetchCartData();
  }

  Future<void> fetchCartData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userId = supabase.auth.currentUser!.id;

      final booking = await supabase
          .from('tbl_booking')
          .select()
          .eq('user_id', userId)
          .eq('booking_status', 0)
          .maybeSingle();

      if (booking == null) {
        setState(() {
          cartItems = [];
          isLoading = false;
        });
        return;
      }

      final response = await supabase
          .from('tbl_cart')
          .select('*, tbl_product(*)')
          .eq('booking_id', booking['booking_id']);

      setState(() {
        cartItems = List.from(response);
        _calcTotal();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _calcTotal() {
    grandTotal = cartItems.fold(0.0, (sum, item) {
      final price =
          (item['tbl_product']['product_price'] as num?)?.toDouble() ?? 0;

      final qty = item['cart_quantity'] ?? 0;

      return sum + price * qty;
    });
  }

  Future<void> updateQty(int index, int delta) async {
    setState(() => isProcessing = true);

    final newQty = cartItems[index]['cart_quantity'] + delta;

    if (newQty < 1) {
      await deleteItem(cartItems[index]['cart_id'], index);
      setState(() => isProcessing = false);
      return;
    }

    await supabase
        .from('tbl_cart')
        .update({'cart_quantity': newQty})
        .eq('cart_id', cartItems[index]['cart_id']);

    setState(() {
      cartItems[index]['cart_quantity'] = newQty;
      _calcTotal();
      isProcessing = false;
    });
  }

  Future<void> deleteItem(int cartId, int index) async {
    setState(() => isProcessing = true);

    await supabase.from('tbl_cart').delete().eq('cart_id', cartId);

    setState(() {
      cartItems.removeAt(index);
      _calcTotal();
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: bgColor,

          appBar: AppBar(
            title: const Text("My Cart"),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,

            actions: [
             
             ElevatedButton(onPressed: () {
               Navigator.push(
                context, MaterialPageRoute( builder: (context) =>  OrderHistoryPage()));
             }, child: Icon(Icons.history)),
              if (cartItems.isNotEmpty)
                TextButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          for (int i = cartItems.length - 1; i >= 0; i--) {
                            await deleteItem(cartItems[i]['cart_id'], i);
                          }
                        },
                  child: Text(
                    "Clear All",
                    style: TextStyle(
                      color:
                          isProcessing ? Colors.grey : Colors.redAccent,
                    ),
                  ),
                ),
            ],
          ),

          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: primary,
                  ),
                )
              : cartItems.isEmpty
                  ? RefreshIndicator(
                      color: primary,
                      onRefresh: fetchCartData,
                      child: ListView(
                        children: [
                          SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 0.8,
                            child: _buildEmpty(),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: primary,
                      onRefresh: fetchCartData,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: cartItems.length,
                              itemBuilder: (ctx, i) =>
                                  _buildItem(cartItems[i], i),
                            ),
                          ),

                          _buildCheckout(),
                        ],
                      ),
                    ),
        ),

        if (isProcessing)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(
                color: primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildItem(Map item, int index) {
    final product = item['tbl_product'];

    final double price =
        (product['product_price'] as num?)?.toDouble() ?? 0;

    final int qty = item['cart_quantity'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          children: [
            SizedBox(
              height: 100,
              width: 90,

              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),

                child: product['product_photo'] != null
                    ? Image.network(
                        product['product_photo'],
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image),
                      ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    product['product_name'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "₹${(price * qty).toStringAsFixed(0)}",

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _qtyBtn(
                        Icons.remove,
                        isProcessing
                            ? () {}
                            : () => updateQty(index, -1),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),

                        child: Text(
                          "$qty",

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      _qtyBtn(
                        Icons.add,
                        isProcessing
                            ? () {}
                            : () => updateQty(index, 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: isProcessing
                        ? null
                        : () => deleteItem(item['cart_id'], index),

                    child: const Text(
                      "Remove",

                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w500,
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
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(6),

        decoration: BoxDecoration(
          color: primary.withOpacity(.1),
          shape: BoxShape.circle,
        ),

        child: Icon(
          icon,
          size: 18,
          color: primary,
        ),
      ),
    );
  }

  Widget _buildCheckout() {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),

      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              Text(
                "${cartItems.length} item${cartItems.length > 1 ? 's' : ''}",

                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 15,
                ),
              ),

              Text(
                "₹${grandTotal.toStringAsFixed(0)}",

                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,

            child: ElevatedButton(
              onPressed: isProcessing ? null : () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentGatewayScreen(
              id: cartItems[0]['booking_id'],
              amt: grandTotal.toInt(),
            ),
          ),
        ),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 15, 160, 51),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              child: isProcessing
                  ? const CircularProgressIndicator(
                      color: Colors.blue,
                    )
                  : const Text(
                      "Proceed To Pay",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 90,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 20),

          const Text(
            "Your cart is empty",

            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "Add some products to get started",

            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
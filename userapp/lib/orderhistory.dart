import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from('tbl_booking')
          .select('''
            *,
            tbl_cart (
              cart_quantity,
              tbl_product (
                product_name,
                product_price,
                product_photo
              )
            )
          ''')
          .eq('user_id', user.id)
          .neq('booking_status', 0)
          .order('booking_id', ascending: false);

      setState(() {
        orders = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Order Fetch Error: $e");
      setState(() => isLoading = false);
    }
  }

  String getStatusText(int status) {
    switch (status) {
      case 1:
        return "Paid";
      case 2:
        return "Shipped";
      case 3:
        return "Delivered";
      default:
        return "Completed";
    }
  }

  Color getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      default:
        return const Color(0xFF0A6C74);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),

      appBar: AppBar(
        title: const Text("My Orders"),
        backgroundColor: const Color(0xFFF4F7FB),
        foregroundColor: const Color(0xFF0A6C74),
        elevation: 0,
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(
                  child: Text(
                    "No orders placed yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final List items = order['tbl_cart'] ?? [];

                    final statusColor =
                        getStatusColor(order['booking_status']);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ExpansionTile(
                        iconColor: const Color(0xFF0A6C74),
                        collapsedIconColor: const Color(0xFF0A6C74),

                        title: Text(
                          "Order #${order['booking_id']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A6C74),
                          ),
                        ),

                        subtitle: Text(
                          "₹${order['booking_amount']} • ${getStatusText(order['booking_status'])}",
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        children: [
                          const Divider(),

                          /// ITEMS
                          ...items.map((item) {
                            final product = item['tbl_product'];

                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  product['product_photo'] ??
                                      'https://via.placeholder.com/50',
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                product['product_name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text("Qty: ${item['cart_quantity']}"),
                              trailing: Text(
                                "₹${product['product_price']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A6C74),
                                ),
                              ),
                            );
                          }).toList(),

                          const SizedBox(height: 10),

                          /// DATE + STATUS BAR
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F7FB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Order Date:",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(
                                      DateTime.parse(
                                        order['created_at'] ??
                                            DateTime.now().toString(),
                                      ),
                                    ),
                                    style: const TextStyle(
                                      color: Color(0xFF0A6C74),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
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
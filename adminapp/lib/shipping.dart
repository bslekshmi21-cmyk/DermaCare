import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class OrderDispatcherPage extends StatefulWidget {
  const OrderDispatcherPage({super.key});

  @override
  State<OrderDispatcherPage> createState() => _OrderDispatcherPageState();
}

class _OrderDispatcherPageState extends State<OrderDispatcherPage> {
  final Color primaryColor = const Color(0xFF0A0A5A);

  Future<void> _updateStatus(int bookingId, int newStatus) async {
    try {
      await supabase
          .from('tbl_booking')
          .update({'booking_status': newStatus})
          .eq('booking_id', bookingId);

      setState(() {});
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),

        appBar: AppBar(
          title: const Text("Order Dispatcher"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,

          bottom: TabBar(
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(
                text: "New Orders",
                icon: Icon(Icons.receipt_long),
              ),
              Tab(
                text: "Shipping",
                icon: Icon(Icons.local_shipping),
              ),
              Tab(
                text: "Shipped",
                icon: Icon(Icons.done_all),
              ),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            _orderList(1, "Mark as Shipping", 2),
            _orderList(2, "Mark as Shipped", 3),
            _orderList(3, "Completed", null),
          ],
        ),
      ),
    );
  }

  Widget _orderList(int status, String btnText, int? nextStatus) {
    return FutureBuilder(
      future: supabase
          .from('tbl_booking')
          .select('''
            *,
            tbl_user(
              user_name,
              user_email
            ),
            tbl_cart(
              *,
              tbl_product(*)
            )
          ''')
          .eq('booking_status', status)
          .order('booking_id', ascending: false),

      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          );
        }

        final orders = snapshot.data as List;

        if (orders.isEmpty) {
          return const Center(
            child: Text(
              "No orders available",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: orders.length,

          itemBuilder: (context, index) {
            final order = orders[index];
            final user = order['tbl_user'];

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),

              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,

                iconColor: primaryColor,
                collapsedIconColor: primaryColor,

                title: Text(
                  "Order #${order['booking_id']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),

                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Total Amount : ₹${order['booking_amount']}",
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "User : ${user?['user_name'] ?? 'No Name'}",
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),

                      Text(
                        "Email : ${user?['user_email'] ?? 'No Email'}",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                children: [

                  const SizedBox(height: 10),

                  const Divider(),

                  ...(order['tbl_cart'] as List).map(
                    (item) => Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),

                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6FA),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),

                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                        children: [

                          Expanded(
                            child: Text(
                              item['tbl_product']
                                      ['product_name'] ??
                                  '',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),

                            child: Text(
                              "x${item['cart_quantity']}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (nextStatus != null)
                    Padding(
                      padding: const EdgeInsets.all(12),

                      child: SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 14,
                            ),

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),

                          onPressed: () {
                            _updateStatus(
                              order['booking_id'],
                              nextStatus,
                            );
                          },

                          child: Text(
                            btnText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
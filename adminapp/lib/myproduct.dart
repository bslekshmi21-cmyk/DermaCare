import 'package:adminapp/addgallery.dart';
import 'package:adminapp/addstock.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Myproduct extends StatefulWidget {
  const Myproduct({super.key});

  @override
  State<Myproduct> createState() => _MyproductState();
}

class _MyproductState extends State<Myproduct> {
  List<Map<String, dynamic>> productList = [];
  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    try {
      final productRes = await supabase.from('tbl_product').select('''
        *,
        tbl_category(category_name),
        tbl_type(type_name),
        tbl_level(level_name),
        tbl_heat(heat_name)
      ''');

      setState(() {
        productList = List<Map<String, dynamic>>.from(productRes);
        _isloading = false;
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
      setState(() => _isloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Product Management"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchAllData,
          ),
        ],
      ),

      /// ✅ FULL PAGE SCROLL FIX
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "All Products",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _isloading
                  ? const Center(child: CircularProgressIndicator())

                  : productList.isEmpty
                      ? const Center(child: Text("No products found"))

                      /// ✅ IMPORTANT FIX HERE
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: productList.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.75,
                          ),
                          itemBuilder: (context, index) {
                            final product = productList[index];

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: product['product_photo'] != null &&
                                              product['product_photo'] != ''
                                          ? Image.network(
                                              product['product_photo'],
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : const Center(
                                              child: Icon(Icons.image, size: 40),
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
                                              fontWeight: FontWeight.w600),
                                        ),

                                        const SizedBox(height: 5),

                                        Text(
                                          "₹${product['product_price'] ?? '0'}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),

                                        const SizedBox(height: 10),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [

                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => Addgallery(
                                                      pid: product['product_id'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.photo,
                                                      size: 18,
                                                      color: Colors.blue),
                                                  SizedBox(width: 5),
                                                  Text("Gallery",
                                                      style:
                                                          TextStyle(fontSize: 12)),
                                                ],
                                              ),
                                            ),

                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => Stock(
                                                      pid: product['product_id'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Row(
                                                children: [
                                                  Icon(Icons.inventory_2,
                                                      size: 18,
                                                      color: Colors.orange),
                                                  SizedBox(width: 5),
                                                  Text("Stock",
                                                      style:
                                                          TextStyle(fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
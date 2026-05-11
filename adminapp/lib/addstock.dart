import 'package:adminapp/addpro.dart';
import 'package:flutter/material.dart';

class Stock extends StatefulWidget {
  const Stock({super.key, required this.pid});

  final int pid;

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  final TextEditingController _stockcount = TextEditingController();

  List<Map<String, dynamic>> stockList = [];
  int eid = 0;

  @override
  void initState() {
    super.initState();
    fetchStock();
  }

  Future<void> fetchStock() async {
    try {
      final response = await supabase.from('tbl_stock').select();

      setState(() {
        stockList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Fetch error: $e");
    }
  }

  Future<void> insertOrUpdate() async {
    try {
      final stockCount = int.tryParse(_stockcount.text.trim()) ?? 0;

      if (eid == 0) {
        await supabase.from('tbl_stock').insert({
          'product_id': widget.pid,
          'stock_count': stockCount,
        });
      } else {
        await supabase.from('tbl_stock').update({
          'stock_count': stockCount,
        }).eq('stock_id', eid);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved Successfully")),
      );

      _stockcount.clear();
      eid = 0;

      fetchStock();
    } catch (e) {
      debugPrint("Insert/Update error: $e");
    }
  }

  Future<void> deleteStock(int id) async {
    try {
      await supabase.from('tbl_stock').delete().eq('stock_id', id);
      fetchStock();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Stock Management"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Manage Stock",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// INPUT CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Stock Count",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: _stockcount,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter stock count",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: insertOrUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A0A5A),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Stock List",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            /// LIST TABLE
            Expanded(
              child: stockList.isEmpty
                  ? const Center(child: Text("No stock available"))
                  : ListView.builder(
                      itemCount: stockList.length,
                      itemBuilder: (context, index) {
                        final stock = stockList[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Text(
                                "Stock: ${stock['stock_count']}",
                                style: const TextStyle(fontSize: 16),
                              ),

                              Row(
                                children: [

                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      setState(() {
                                        eid = stock['stock_id'];
                                        _stockcount.text =
                                            stock['stock_count'].toString();
                                      });
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      deleteStock(stock['stock_id']);
                                    },
                                  ),
                                ],
                              ),
                            ],
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
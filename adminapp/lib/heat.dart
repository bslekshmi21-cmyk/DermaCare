import 'package:adminapp/main.dart';
import 'package:flutter/material.dart';

class Heat extends StatefulWidget {
  const Heat({super.key});

  @override
  State<Heat> createState() => _HeatState();
}

class _HeatState extends State<Heat> {
  final TextEditingController heatController = TextEditingController();

  List<Map<String, dynamic>> heatList = [];
  int eid = 0;

  @override
  void initState() {
    super.initState();
    fetchHeat();
  }

  /// FETCH
  Future<void> fetchHeat() async {
    try {
      final response = await supabase.from('tbl_heat').select();

      setState(() {
        heatList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Fetch error: $e");
    }
  }

  /// INSERT
  Future<void> insertHeat() async {
    try {
      await supabase.from('tbl_heat').insert({
        'heat_name': heatController.text,
      });

      heatController.clear();
      fetchHeat();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Heat Added")),
      );
    } catch (e) {
      debugPrint("Insert error: $e");
    }
  }

  /// UPDATE
  Future<void> updateHeat() async {
    try {
      await supabase.from('tbl_heat').update({
        'heat_name': heatController.text,
      }).eq('heat_id', eid);

      setState(() {
        eid = 0;
        heatController.clear();
      });

      fetchHeat();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Updated Successfully")),
      );
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  /// DELETE
  Future<void> deleteHeat(int id) async {
    try {
      await supabase.from('tbl_heat').delete().eq('heat_id', id);
      fetchHeat();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Heat Management"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            const Text(
              "Manage Heat Levels",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                    "Heat Name",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: heatController,
                    decoration: InputDecoration(
                      hintText: "Enter heat name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () {
                      eid == 0 ? insertHeat() : updateHeat();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A0A5A),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      eid == 0 ? "Add Heat" : "Update Heat",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST TITLE
            const Text(
              "Heat List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            /// LIST
            Expanded(
              child: heatList.isEmpty
                  ? const Center(child: Text("No heat data found"))
                  : ListView.builder(
                      itemCount: heatList.length,
                      itemBuilder: (context, index) {
                        final heat = heatList[index];

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

                              /// NAME
                              Text(
                                heat['heat_name'] ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),

                              /// ACTIONS
                              Row(
                                children: [

                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      setState(() {
                                        eid = heat['heat_id'];
                                        heatController.text =
                                            heat['heat_name'];
                                      });
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      deleteHeat(heat['heat_id']);
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
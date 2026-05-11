import 'package:adminapp/main.dart';
import 'package:flutter/material.dart';

class TypePage extends StatefulWidget {
  const TypePage({super.key});

  @override
  State<TypePage> createState() => _TypePageState();
}

class _TypePageState extends State<TypePage> {
  final TextEditingController typeController = TextEditingController();

  List<Map<String, dynamic>> typeList = [];
  int eid = 0;

  @override
  void initState() {
    super.initState();
    fetchType();
  }

  /// FETCH
  Future<void> fetchType() async {
    try {
      final response = await supabase.from('tbl_type').select();

      setState(() {
        typeList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Fetch error: $e");
    }
  }

  /// INSERT
  Future<void> insertType() async {
    try {
      await supabase.from('tbl_type').insert({
        'type_name': typeController.text
      });

      typeController.clear();
      fetchType();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Type Added")),
      );
    } catch (e) {
      debugPrint("Insert error: $e");
    }
  }

  /// UPDATE
  Future<void> updateType() async {
    try {
      await supabase.from('tbl_type').update({
        'type_name': typeController.text
      }).eq('type_id', eid);

      setState(() {
        eid = 0;
        typeController.clear();
      });

      fetchType();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Updated Successfully")),
      );
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  /// DELETE
  Future<void> deleteType(int id) async {
    try {
      await supabase.from('tbl_type').delete().eq('type_id', id);
      fetchType();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Skin Type Management"),
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
              "Manage Skin Types",
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
                    "Skin Type",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: typeController,
                    decoration: InputDecoration(
                      hintText: "Enter skin type",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () {
                      eid == 0 ? insertType() : updateType();
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
                      eid == 0 ? "Add Type" : "Update Type",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST TITLE
            const Text(
              "Type List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            /// LIST
            Expanded(
              child: typeList.isEmpty
                  ? const Center(child: Text("No types found"))
                  : ListView.builder(
                      itemCount: typeList.length,
                      itemBuilder: (context, index) {
                        final type = typeList[index];

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
                                type['type_name'] ?? '',
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
                                        eid = type['type_id'];
                                        typeController.text =
                                            type['type_name'];
                                      });
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      deleteType(type['type_id']);
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
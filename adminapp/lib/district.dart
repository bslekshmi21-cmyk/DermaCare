import 'package:adminapp/main.dart';
import 'package:flutter/material.dart';

class distr extends StatefulWidget {
  const distr({super.key});

  @override
  State<distr> createState() => _distrState();
}

class _distrState extends State<distr> {
  TextEditingController districtController = TextEditingController();
  List<Map<String, dynamic>> districtList = [];
  int eid = 0;

  @override
  void initState() {
    super.initState();
    fetchDistrict();
  }

  Future<void> insert() async {
    try {
      await supabase.from('tbl_district').insert({
        'district_name': districtController.text
      });

      districtController.clear();
      fetchDistrict();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("District Added")),
      );
    } catch (e) {
      debugPrint("Insert Error $e");
    }
  }

  Future<void> updateDistrict() async {
    try {
      await supabase.from('tbl_district').update({
        'district_name': districtController.text
      }).eq('district_id', eid);

      eid = 0;
      districtController.clear();
      fetchDistrict();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Updated Successfully")),
      );

      setState(() {});
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  Future<void> fetchDistrict() async {
    try {
      final response = await supabase.from('tbl_district').select();
      setState(() {
        districtList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Fetch Error $e");
    }
  }

  void deleteDistrict(int id) async {
    try {
      await supabase.from('tbl_district').delete().eq('district_id', id);
      fetchDistrict();
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("District Management"),
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
              "Manage Districts",
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
                    "District Name",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: districtController,
                    decoration: InputDecoration(
                      hintText: "Enter district name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () {
                      eid == 0 ? insert() : updateDistrict();
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
                      eid == 0 ? "Add District" : "Update District",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST TITLE
            const Text(
              "District List",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            /// LIST
            Expanded(
              child: districtList.isEmpty
                  ? const Center(child: Text("No districts found"))
                  : ListView.builder(
                      itemCount: districtList.length,
                      itemBuilder: (context, index) {
                        final district = districtList[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [

                              /// NAME
                              Text(
                                district['district_name'] ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),

                              /// ACTIONS
                              Row(
                                children: [

                                  /// EDIT
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      setState(() {
                                        eid = district['district_id'];
                                        districtController.text =
                                            district['district_name'];
                                      });
                                    },
                                  ),

                                  /// DELETE
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      deleteDistrict(
                                          district['district_id']);
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
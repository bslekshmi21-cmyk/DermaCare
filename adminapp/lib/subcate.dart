import 'package:adminapp/main.dart';
import 'package:flutter/material.dart';

class Subcate extends StatefulWidget {
  const Subcate({super.key});

  @override
  State<Subcate> createState() => _SubcateState();
}

class _SubcateState extends State<Subcate> {
  TextEditingController subcatecontroller = TextEditingController();

  List<Map<String, dynamic>> categorylist = [];
  List<Map<String, dynamic>> subcategoryList = [];

  String? _selectedValue;
  int eid = 0;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await fetchCategories();
    await fetchSubcategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await supabase.from('tbl_category').select();

      setState(() {
        categorylist = List<Map<String, dynamic>>.from(response);

        if (categorylist.isNotEmpty) {
          _selectedValue = categorylist[0]['category_id'].toString();
        }
      });
    } catch (e) {
      debugPrint("Category error: $e");
    }
  }

  Future<void> fetchSubcategories() async {
    try {
      final response = await supabase
          .from('tbl_subcategory')
          .select('*, tbl_category(category_name)');

      setState(() {
        subcategoryList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Subcategory error: $e");
    }
  }

  Future<void> insertSub() async {
    if (subcatecontroller.text.isEmpty || _selectedValue == null) return;

    await supabase.from('tbl_subcategory').insert({
      'subcategory_name': subcatecontroller.text,
      'category_id': int.parse(_selectedValue!),
    });

    subcatecontroller.clear();
    _selectedValue = null;

    fetchSubcategories();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Subcategory Added")),
    );
  }

  Future<void> updateSub() async {
    await supabase.from('tbl_subcategory').update({
      'subcategory_name': subcatecontroller.text,
      'category_id': int.parse(_selectedValue!),
    }).eq('subcategory_id', eid);

    setState(() {
      eid = 0;
      subcatecontroller.clear();
      _selectedValue = null;
    });

    fetchSubcategories();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Updated Successfully")),
    );
  }

  void deleteSub(int id) async {
    await supabase.from('tbl_subcategory').delete().eq('subcategory_id', id);
    fetchSubcategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Subcategory Management"),
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
              "Manage Subcategories",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// FORM CARD
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

                  const Text("Category",
                      style: TextStyle(fontWeight: FontWeight.w600)),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: _selectedValue,
                    items: categorylist.map((c) {
                      return DropdownMenuItem(
                        value: c['category_id'].toString(),
                        child: Text(c['category_name']),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedValue = val),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text("Subcategory",
                      style: TextStyle(fontWeight: FontWeight.w600)),

                  const SizedBox(height: 8),

                  TextField(
                    controller: subcatecontroller,
                    decoration: InputDecoration(
                      hintText: "Enter subcategory",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () {
                      eid == 0 ? insertSub() : updateSub();
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
                      eid == 0 ? "Add Subcategory" : "Update Subcategory",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Subcategory List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            /// LIST (LIKE PLACE PAGE)
            Expanded(
              child: subcategoryList.isEmpty
                  ? const Center(child: Text("No subcategories found"))
                  : ListView.builder(
                      itemCount: subcategoryList.length,
                      itemBuilder: (context, index) {
                        final sub = subcategoryList[index];

                        final catData = sub['tbl_category'];
                        String catName = catData is Map
                            ? catData['category_name']
                            : "N/A";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [

                              /// INFO
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sub['subcategory_name'] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    catName,
                                    style:
                                        const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),

                              /// ACTION
                              Row(
                                children: [

                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      setState(() {
                                        eid = sub['subcategory_id'];
                                        subcatecontroller.text =
                                            sub['subcategory_name'];
                                        _selectedValue =
                                            sub['category_id'].toString();
                                      });
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        deleteSub(sub['subcategory_id']),
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
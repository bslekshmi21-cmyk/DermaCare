import 'package:adminapp/main.dart';
import 'package:flutter/material.dart';

class cate extends StatefulWidget {
  const cate({super.key});

  @override
  State<cate> createState() => _cateState();
}

class _cateState extends State<cate> {
  TextEditingController category_controller = TextEditingController();
  List<Map<String, dynamic>> categoryList = [];
  int eid = 0;

  @override
  void initState() {
    super.initState();
    fetchCategory();
  }

  Future<void> insert() async {
    try {
      await supabase.from('tbl_category').insert({
        'category_name': category_controller.text
      });

      category_controller.clear();
      fetchCategory();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Category Added")),
      );
    } catch (e) {
      debugPrint("Insert Error $e");
    }
  }

  Future<void> updateCategory() async {
    try {
      await supabase.from('tbl_category').update({
        'category_name': category_controller.text
      }).eq('category_id', eid);

      eid = 0;
      category_controller.clear();
      fetchCategory();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Updated Successfully")),
      );

      setState(() {});
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  Future<void> fetchCategory() async {
    try {
      final response = await supabase.from('tbl_category').select();
      setState(() {
        categoryList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Fetch Error $e");
    }
  }

  void deleteCategory(int id) async {
    try {
      await supabase.from('tbl_category').delete().eq('category_id', id);
      fetchCategory();
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Category Management"),
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
              "Manage Categories",
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
                    "Category Name",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: category_controller,
                    decoration: InputDecoration(
                      hintText: "Enter category name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () {
                      eid == 0 ? insert() : updateCategory();
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
                      eid == 0 ? "Add Category" : "Update Category",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST TITLE
            const Text(
              "Category List",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            /// LIST
            Expanded(
              child: categoryList.isEmpty
                  ? const Center(child: Text("No categories found"))
                  : ListView.builder(
                      itemCount: categoryList.length,
                      itemBuilder: (context, index) {
                        final category = categoryList[index];

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

                              /// NAME
                              Text(
                                category['category_name'] ?? '',
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
                                        eid = category['category_id'];
                                        category_controller.text =
                                            category['category_name'];
                                      });
                                    },
                                  ),

                                  /// DELETE
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      deleteCategory(
                                          category['category_id']);
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
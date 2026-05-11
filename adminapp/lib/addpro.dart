import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

final supabase = Supabase.instance.client;

class Addpro extends StatefulWidget {
  const Addpro({super.key});

  @override
  State<Addpro> createState() => _AddproState();
}

class _AddproState extends State<Addpro> {
  Uint8List? imageBytes;
  PlatformFile? pickedImage;

  List<Map<String, dynamic>> productList = [];
  List<Map<String, dynamic>> categoryList = [];
  List<Map<String, dynamic>> typeList = [];
  List<Map<String, dynamic>> levelList = [];
  List<Map<String, dynamic>> heatList = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController photoController = TextEditingController();

  String? selectedCategory;
  String? selectedType;
  String? selectedLevel;
  String? selectedHeatAbsorbtion;

  String? editingId;

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  Future<void> fetchAll() async {
    final productRes = await supabase.from('tbl_product').select('''
      *,
      tbl_category(category_name),
      tbl_type(type_name),
      tbl_level(level_name),
      tbl_heat(heat_name)
    ''');

    final catRes = await supabase.from('tbl_category').select();
    final typeRes = await supabase.from('tbl_type').select();
    final levelRes = await supabase.from('tbl_level').select();
    final heatRes = await supabase.from('tbl_heat').select();

    setState(() {
      productList = List<Map<String, dynamic>>.from(productRes);
      categoryList = List<Map<String, dynamic>>.from(catRes);
      typeList = List<Map<String, dynamic>>.from(typeRes);
      levelList = List<Map<String, dynamic>>.from(levelRes);
      heatList = List<Map<String, dynamic>>.from(heatRes);
    });
  }

  Future<void> pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        pickedImage = result.files.first;
        imageBytes = pickedImage!.bytes;
        photoController.text = pickedImage!.name;
      });
    }
  }

  Future<void> deleteProduct(int id) async {
    await supabase.from('tbl_product').delete().eq('product_id', id);
    fetchAll();
  }

  Future<void> saveProduct() async {
    String? imageUrl;

    if (imageBytes != null) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      await supabase.storage
          .from('product_photo')
          .uploadBinary('products/$fileName.jpg', imageBytes!);

      imageUrl = supabase.storage
          .from('product_photo')
          .getPublicUrl('products/$fileName.jpg');
    }

    final data = {
      'product_name': nameController.text,
      'product_description': descController.text,
      'product_price': priceController.text,
      'category_id': selectedCategory,
      'type_id': selectedType,
      'level_id': selectedLevel,
      'heat_id': selectedHeatAbsorbtion, // ✅ renamed
      if (imageUrl != null) 'product_photo': imageUrl,
    };

    if (editingId == null) {
      await supabase.from('tbl_product').insert(data);
    } else {
      await supabase
          .from('tbl_product')
          .update(data)
          .eq('product_id', editingId as Object);
    }

    clearForm();
    fetchAll();
  }

  void clearForm() {
    nameController.clear();
    descController.clear();
    priceController.clear();
    photoController.clear();

    setState(() {
      selectedCategory = null;
      selectedType = null;
      selectedLevel = null;
      selectedHeatAbsorbtion = null;
      imageBytes = null;
      pickedImage = null;
      editingId = null;
    });
  }

  Widget buildField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget buildDropdown(
    String label,
    List<Map<String, dynamic>> items,
    String nameKey,
    String idKey,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e[idKey].toString(),
                  child: Text(e[nameKey]),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
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
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              const Text(
                "Manage Products",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              /// FORM
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [

                    buildField("Name", nameController),
                    buildField("Description", descController),

                    buildDropdown("Category", categoryList, "category_name",
                        "category_id", (v) => selectedCategory = v),

                    buildDropdown("Type", typeList, "type_name",
                        "type_id", (v) => selectedType = v),

                    buildDropdown("Level", levelList, "level_name",
                        "level_id", (v) => selectedLevel = v),

                    /// ✅ HEAT ABSORPTION
                    buildDropdown("Heat Absorbtion", heatList, "heat_name",
                        "heat_id", (v) => selectedHeatAbsorbtion = v),

                    buildField("Price", priceController),

                    TextField(
                      controller: photoController,
                      readOnly: true,
                      onTap: pickImage,
                      decoration: const InputDecoration(
                        hintText: "Upload Image",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A0A5A),
                        ),
                        onPressed: saveProduct,
                        child: Text(
                          editingId == null ? "Add Product" : "Update Product",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// LIST
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  final p = productList[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [

                        /// IMAGE SMALL
                        if (p['product_photo'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              p['product_photo'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),

                        const SizedBox(width: 10),

                        /// DETAILS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p['product_name'] ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),

                              Text("₹${p['product_price']}"),

                              Text(
                                p['product_description'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              Text("Level: ${p['tbl_level']?['level_name'] ?? ''}"),
                              Text("Category: ${p['tbl_category']?['category_name'] ?? ''}"),
                              Text("Type: ${p['tbl_type']?['type_name'] ?? ''}"),
                              Text("Heat Absorbtion: ${p['tbl_heat']?['heat_name'] ?? ''}"),
                            ],
                          ),
                        ),

                        /// ACTIONS
                        Row(
                          children: [

                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                setState(() {
                                  editingId = p['product_id'].toString();
                                  nameController.text = p['product_name'];
                                  descController.text = p['product_description'];
                                  priceController.text = p['product_price'];

                                  selectedCategory = p['category_id']?.toString();
                                  selectedType = p['type_id']?.toString();
                                  selectedLevel = p['level_id']?.toString();
                                  selectedHeatAbsorbtion = p['heat_id']?.toString();
                                });
                              },
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  deleteProduct(p['product_id']),
                            ),
                          ],
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
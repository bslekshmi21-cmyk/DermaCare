import 'package:adminapp/main.dart';
import 'package:flutter/material.dart';

class Level extends StatefulWidget {
  const Level({super.key});

  @override
  State<Level> createState() => _LevelState();
}

class _LevelState extends State<Level> {
  final TextEditingController levelController = TextEditingController();

  List<Map<String, dynamic>> levelList = [];
  int eid = 0;

  @override
  void initState() {
    super.initState();
    fetchLevel();
  }

  /// FETCH
  Future<void> fetchLevel() async {
    try {
      final response = await supabase.from('tbl_level').select();

      setState(() {
        levelList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Fetch error: $e");
    }
  }

  /// INSERT
  Future<void> insertLevel() async {
    try {
      await supabase.from('tbl_level').insert({
        'level_name': levelController.text
      });

      levelController.clear();
      fetchLevel();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Level Added")),
      );
    } catch (e) {
      debugPrint("Insert error: $e");
    }
  }

  /// UPDATE
  Future<void> updateLevel() async {
    try {
      await supabase.from('tbl_level').update({
        'level_name': levelController.text
      }).eq('level_id', eid);

      setState(() {
        eid = 0;
        levelController.clear();
      });

      fetchLevel();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Updated Successfully")),
      );
    } catch (e) {
      debugPrint("Update error: $e");
    }
  }

  /// DELETE
  Future<void> deleteLevel(int id) async {
    try {
      await supabase.from('tbl_level').delete().eq('level_id', id);
      fetchLevel();
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Level Management"),
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
              "Manage Levels",
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
                    "Level Name",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: levelController,
                    decoration: InputDecoration(
                      hintText: "Enter level name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () {
                      eid == 0 ? insertLevel() : updateLevel();
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
                      eid == 0 ? "Add Level" : "Update Level",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST TITLE
            const Text(
              "Level List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            /// LIST
            Expanded(
              child: levelList.isEmpty
                  ? const Center(child: Text("No levels found"))
                  : ListView.builder(
                      itemCount: levelList.length,
                      itemBuilder: (context, index) {
                        final level = levelList[index];

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
                                level['level_name'] ?? '',
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
                                        eid = level['level_id'];
                                        levelController.text =
                                            level['level_name'];
                                      });
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      deleteLevel(level['level_id']);
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
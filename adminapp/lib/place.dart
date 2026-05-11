import 'package:adminapp/main.dart';
import 'package:flutter/material.dart';

class Place extends StatefulWidget {
  const Place({super.key});

  @override
  State<Place> createState() => _PlaceState();
}

class _PlaceState extends State<Place> {
  TextEditingController placecontroller = TextEditingController();
  List<Map<String, dynamic>> districtlist = [];
  List<Map<String, dynamic>> placelist = [];
  String? _selectedValue;
  int eid = 0;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await fetchDistrict();
    await fetchPlace();
  }

  Future<void> fetchDistrict() async {
    try {
      final response = await supabase.from('tbl_district').select();
      setState(() {
        districtlist = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("District error: $e");
    }
  }

  Future<void> fetchPlace() async {
    try {
      final response = await supabase
          .from('tbl_place')
          .select('*, tbl_district(district_name)');

      setState(() {
        placelist = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Place error: $e");
    }
  }

  Future<void> insertPlace() async {
    if (placecontroller.text.isEmpty || _selectedValue == null) return;

    await supabase.from('tbl_place').insert({
      'place_name': placecontroller.text,
      'district_id': int.parse(_selectedValue!),
    });

    placecontroller.clear();
    _selectedValue = null;
    fetchPlace();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Place Added")),
    );
  }

  Future<void> updatePlace() async {
    await supabase.from('tbl_place').update({
      'place_name': placecontroller.text,
      'district_id': int.parse(_selectedValue!),
    }).eq('place_id', eid);

    setState(() {
      eid = 0;
      placecontroller.clear();
      _selectedValue = null;
    });

    fetchPlace();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Updated Successfully")),
    );
  }

  void deletePlace(int id) async {
    await supabase.from('tbl_place').delete().eq('place_id', id);
    fetchPlace();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("Place Management"),
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
              "Manage Places",
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

                  const Text("District",
                      style: TextStyle(fontWeight: FontWeight.w600)),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: _selectedValue,
                    items: districtlist.map((d) {
                      return DropdownMenuItem(
                        value: d['district_id'].toString(),
                        child: Text(d['district_name']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedValue = val),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text("Place Name",
                      style: TextStyle(fontWeight: FontWeight.w600)),

                  const SizedBox(height: 8),

                  TextField(
                    controller: placecontroller,
                    decoration: InputDecoration(
                      hintText: "Enter place name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () {
                      eid == 0 ? insertPlace() : updatePlace();
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
                      eid == 0 ? "Add Place" : "Update Place",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Place List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            /// LIST
            Expanded(
              child: placelist.isEmpty
                  ? const Center(child: Text("No places found"))
                  : ListView.builder(
                      itemCount: placelist.length,
                      itemBuilder: (context, index) {
                        final place = placelist[index];

                        final districtData = place['tbl_district'];
                        String distName = districtData is Map
                            ? districtData['district_name']
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              /// INFO
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(place['place_name'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  Text(distName,
                                      style: const TextStyle(
                                          color: Colors.grey)),
                                ],
                              ),

                              /// ACTIONS
                              Row(
                                children: [

                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      setState(() {
                                        eid = place['place_id'];
                                        placecontroller.text =
                                            place['place_name'];
                                        _selectedValue =
                                            place['district_id'].toString();
                                      });
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        deletePlace(place['place_id']),
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
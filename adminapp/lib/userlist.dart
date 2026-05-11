import 'package:adminapp/main.dart';
import 'package:flutter/material.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<Map<String, dynamic>> userlist1 = [];

  @override
  void initState() {
    super.initState();
    fetchuserlist();
  }

  Future<void> fetchuserlist() async {
    try {
      final response =
          await supabase.from('tbl_user').select('*,tbl_type(type_name)');

      setState(() {
        userlist1 = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      debugPrint("Error $e");
    }
  }

  Future<void> updateUserStatus(dynamic uid, String status) async {
    try {
      await supabase
          .from('tbl_user')
          .update({'user_status': status}).eq('user_id', uid);

      fetchuserlist();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User marked as $status")),
        );
      }
    } catch (e) {
      debugPrint("Status Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text("User Management"),
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
              "Manage Users",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// LIST
            Expanded(
              child: userlist1.isEmpty
                  ? const Center(child: Text("No users found"))
                  : ListView.builder(
                      itemCount: userlist1.length,
                      itemBuilder: (context, index) {
                        final user = userlist1[index];

                        final typeData = user['tbl_type'];
                        String typeName =
                            typeData is Map ? typeData['type_name'] : "N/A";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
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

                              /// LEFT SIDE (DETAILS)
                              Row(
                                children: [

                                  /// IMAGE
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage:
                                        user['user_photo'] != null
                                            ? NetworkImage(
                                                user['user_photo'])
                                            : null,
                                    child: user['user_photo'] == null
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),

                                  const SizedBox(width: 12),

                                  /// INFO
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user['user_name'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(user['user_email'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                      Text("Type: $typeName",
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                      Text(
                                        "Status: ${user['user_status'] ?? 'pending'}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              /// ACTION BUTTONS
                              Row(
                                children: [

                                  IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: () => updateUserStatus(
                                        user['user_id'], 'active'),
                                  ),

                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () => updateUserStatus(
                                        user['user_id'], 'inactive'),
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
import 'package:dermatologist_app/dermodata.dart';
import 'package:dermatologist_app/profile.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final supabase = Supabase.instance.client;

  String name = "";
  String photo = "";
  bool isLoading = true;

  Future<void> fetchProfile() async {
    try {
      final dermo = supabase.auth.currentUser;
      if (dermo == null) return;

      final response = await supabase
          .from('tbl_dermatologist')
          .select()
          .eq('dermatologist_id', dermo.id)
          .single();

      setState(() {
        name = response['dermatologist_name'] ?? "";
        photo = response['dermatologist_photo'] ?? "";
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 226, 228, 240),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : Column(
              children: [

                /// HEADER (OLD STYLE)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Padding(
                      padding: const EdgeInsets.all(38.0),
                      child: Column(
                        children: [
                          const Text(
                            'Welcome back',
                            style: TextStyle(
                              color: Color.fromARGB(255, 4, 101, 108),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 4, 101, 108),
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Profile(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor:
                              const Color.fromARGB(255, 226, 228, 240),
                          backgroundImage: (photo.isNotEmpty)
                              ? NetworkImage(photo)
                              : const AssetImage('assets/docc1.png')
                                  as ImageProvider,
                        ),
                      ),
                    ),
                  ],
                ),

                /// NOTIFICATION CARD (OLD)
                Container(
                  height: 70,
                  width: 400,
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    elevation: 3,
                    color: const Color.fromARGB(255, 12, 114, 122),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          child: Icon(
                            Icons.notifications_active,
                            color: Color.fromARGB(255, 211, 190, 7),
                          ),
                        ),
                        Text(
                          "You have 0 pending request",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                /// STATS (OLD DESIGN)
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      _OldCard(icon: Icons.calendar_today, value: "3", label: "Total"),
                      _OldCard(icon: Icons.more_horiz_outlined, value: "0", label: "Pending"),
                      _OldCard(icon: Icons.done, value: "3", label: "Done"),
                    ],
                  ),
                ),

                /// EARNINGS (OLD)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Container(
                        height: 80,
                        width: 380,
                        child: Card(
                          elevation: 3,
                          color: const Color.fromARGB(255, 142, 213, 218),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "₹1500",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 4, 101, 108),
                                ),
                              ),
                              Icon(Icons.currency_rupee,
                                  color: Color.fromARGB(255, 4, 101, 108)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                /// TITLE
                const Padding(
                  padding: EdgeInsets.all(28.0),
                  child: Row(
                    children: [
                      Text(
                        "Recent Consultation",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 10, 111, 118),
                        ),
                      ),
                    ],
                  ),
                ),

                /// LIST (UNCHANGED LOGIC)
                Expanded(
                  child: ListView.builder(
                    itemCount: dermo.length,
                    itemBuilder: (context, index) {
                      final pro = dermo[index];

                      return Card(
                        margin: const EdgeInsets.all(10),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(pro['image']),
                          ),
                          title: Text(
                            pro['pname'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 4, 101, 108),
                            ),
                          ),
                          subtitle: Text(pro['time']),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 136, 201, 206),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Accepted",
                              style: TextStyle(
                                color: Color.fromARGB(255, 4, 101, 108),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

/// OLD CARD STYLE WIDGET
class _OldCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _OldCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      color: const Color.fromARGB(255, 226, 228, 240),
      child: Card(
        elevation: 3,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: const Color.fromARGB(255, 12, 144, 154)),
            Text(value,
                style: const TextStyle(
                    fontSize: 20, color: Colors.black)),
            Text(label, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
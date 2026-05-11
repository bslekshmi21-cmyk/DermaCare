import 'package:dermatologist_app/dermodata.dart';
import 'package:flutter/material.dart';

class Dermopage extends StatefulWidget {
  const Dermopage({super.key});

  @override
  State<Dermopage> createState() => _DermopageState();
}

class _DermopageState extends State<Dermopage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: const Color.fromARGB(255, 227, 224, 224),
      appBar: AppBar(backgroundColor: const Color.fromARGB(255, 227, 224, 224)),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
              ),
              itemCount: dermo.length,
              itemBuilder: (context, index) {
                final pro = dermo[index];
                return GestureDetector(
                  onTap: () => 

                  Card(
                    margin: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(pro['image'], fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            pro['pname'],
                            style: TextStyle(
                              color: Color.fromARGB(255, 46, 116, 49),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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
import 'package:adminapp/login.dart';
import 'package:flutter/material.dart';


class Fordpass extends StatefulWidget {
  const Fordpass({super.key});

  @override
  State<Fordpass> createState() => _FordpassState();
}

class _FordpassState extends State<Fordpass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( backgroundColor:const Color.fromARGB(255, 197, 220, 239),
       appBar: AppBar(
        backgroundColor:   const Color.fromARGB(255, 3, 1, 79),
        title: Center(
          child: Text('InputX',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),),
        ),),
      body: Form(child: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text('Enter your email address to recieve a reset link and regain access to your account',
                textAlign: TextAlign.center,style: TextStyle(color: const Color.fromARGB(255, 144, 139, 139),fontSize: 13),
              ),
                ),
                SizedBox(width: 500,height: 100,
                  child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                  decoration: InputDecoration(
                    label: Text('Email address', style: TextStyle(color:  const Color.fromARGB(255, 96, 94, 156),),),
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: Icon(Icons.email,color:  const Color.fromARGB(255, 56, 53, 127),),
                  ),
                              ),
                            ),
                ),
           ElevatedButton(  style: ButtonStyle(
                              backgroundColor: WidgetStateColor.resolveWith((states) =>  const Color.fromARGB(255, 41, 38, 129),),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Continue',style: TextStyle(color: Colors.white,fontSize: 15),),
                            ),
                          ),
            ],
        ),
      ),
      ),
    );
  }
}
import 'package:adminapp/login.dart';
import 'package:flutter/material.dart';


class Createac extends StatefulWidget {
  const Createac({super.key});

  @override
  State<Createac> createState() => _CreateacState();
}

class _CreateacState extends State<Createac> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color.fromARGB(255, 197, 220, 239),
       appBar: AppBar(
        backgroundColor:   const Color.fromARGB(255, 3, 1, 79),
        title: Center(
          child: Text('InputX',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),),
        ),
       ),
      body: Form(child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text('Create a new account to get start and enjoy our seamless access to our features',
              textAlign: TextAlign.center,style: TextStyle(color: const Color.fromARGB(255, 144, 139, 139),fontSize: 13),),
              ),
              SizedBox(width: 500,height: 300,
                child: Column(
                  children: [
                    Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                    decoration: InputDecoration(
                      label: Text('Name',style: TextStyle(color: const Color.fromARGB(255, 96, 94, 156),fontSize: 15),),
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),
                      ),
                      prefixIcon: Icon(Icons.person,color:  const Color.fromARGB(255, 56, 53, 127),),
                    ),
                                ),
                              ),
                     Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                    decoration: InputDecoration(
                      label: Text('Email address',style: TextStyle(color:  const Color.fromARGB(255, 96, 94, 156),fontSize: 15),),
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),
                      ),
                      prefixIcon: Icon(Icons.email,color:  const Color.fromARGB(255, 56, 53, 127),),
                    ),
                                ),
                              ),
                               Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                    decoration: InputDecoration(
                      label: Text('Password',style: TextStyle(color: const Color.fromARGB(255, 96, 94, 156),fontSize: 15),),
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),
                      ),
                      suffixIcon: Icon(Icons.visibility_off,color:  const Color.fromARGB(255, 88, 87, 131),),
                      prefixIcon: Icon(Icons.lock,color: const Color.fromARGB(255, 56, 53, 127),),
                    ),
                                ),
                              ),
                               Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                    decoration: InputDecoration(
                      label: Text('Confirm Password',style: TextStyle(color:const Color.fromARGB(255, 96, 94, 156),fontSize: 15),),
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),
                      ),
                      suffixIcon: Icon(Icons.visibility_off,color:   const Color.fromARGB(255, 88, 87, 131),),
                      prefixIcon: Icon(Icons.lock,color:  const Color.fromARGB(255, 56, 53, 127),),
                    ),
                                ),
                              ),
                  ],
                ),
              ),
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: ElevatedButton(  style: ButtonStyle(
                              backgroundColor: WidgetStateColor.resolveWith((states) =>const Color.fromARGB(255, 41, 38, 129),),
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
                              padding: const EdgeInsets.all(18.0),
                              child: Text('Create Acount',style: TextStyle(color: Colors.white,fontSize: 15),),
                            ),
                          ),
           ),
             Text("Already have an account?",
              textAlign: TextAlign.center,style: TextStyle(color: const Color.fromARGB(255, 119, 115, 115),fontSize: 13),),
              TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Login(),
                              ),
                            );
                          },
                          child: Text('Sign In here',style: TextStyle(color: const Color.fromARGB(255, 41, 38, 129),),)
                        ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: TextFormField()

              ),
             Text('Or Continue With Account',style: TextStyle(color: const Color.fromARGB(255, 124, 118, 118),fontSize: 13),),
               SizedBox(width: 80,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.facebook, color: Colors.blueAccent),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.apple),
                    ),
                ],
              ),
            )
          ],
      ),
      
      )
    );
  }
}

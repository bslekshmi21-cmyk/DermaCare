

import 'package:adminapp/main.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegistationState();
}

class _RegistationState extends State<Register> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> insert() async {
    try {
      final name=nameController.text;
     final email=emailController.text;
     final password=passwordController.text;
       final authResponse = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      final uid = authResponse.user?.id;

      await supabase.from('tbl_admin').insert({'admin_name':name,'admin_email':email,'admin_password':password,
      
        'admin_id': uid,
      
      });
      print("$name inserted");
      print("$email inserted");
      print("$password inserted");
      ScaffoldMessenger.of(
        context,
        ).showSnackBar(SnackBar(content:Text("Data Inserted")));
        nameController.clear();
        emailController.clear();
        passwordController.clear();

    } catch (e) {
      print("Error $e");
      
    }

  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 197, 220, 239),
      appBar: AppBar(
        backgroundColor:const Color.fromARGB(255, 3, 1, 79),
        title: Center(child: Text('Admin Register', style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),),
        ),
      ),
      body: Form(child: Padding(
        padding: const EdgeInsets.all(100),
        child: Center(
          child: SizedBox(width: 500,
            child: Column(
              children: [
                 Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        label: Text(
                          'Name',
                          style: TextStyle(
                            color:const Color.fromARGB(255, 3, 1, 79),
                            fontSize: 15,
                          ),
                        ),
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: Icon(Icons.person,color: const Color.fromARGB(255, 3, 1, 79),),
                      ),
                    ),
                  ),
                   Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        label: Text(
                          'Email address',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 3, 1, 79),
                            fontSize: 15,
                          ),
                        ),
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: Icon(Icons.email,color: const Color.fromARGB(255, 3, 1, 79),),
                      ),
                    ),
                  ),
              
               
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        label: Text(
                          'Password',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 3, 1, 79),
                            fontSize: 15,
                          ),
                        ),
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        prefixIcon: Icon(Icons.visibility_off,color: const Color.fromARGB(255, 3, 1, 79),),
                      ),
                    ),
                  ),
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Center(
                                     child: ElevatedButton(
                                       style: ButtonStyle(
                      backgroundColor: WidgetStateColor.resolveWith(
                        (states) => const Color.fromARGB(255, 3, 1, 79),
                      ),
                                       ),
                                       onPressed: () {
                                        insert();
                      
                                       },
                                       child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                                       ),
                                     ),
                                   ),
                   ),
              ],
              
              
            ),
          ),
        ),
      )),
    );
  }
}
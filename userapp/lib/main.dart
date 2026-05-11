import 'package:flutter/material.dart';
import 'package:userapp/complaint.dart';
import 'package:userapp/createac.dart';
import 'package:userapp/fordpass.dart';
import 'package:userapp/home.dart';
import 'package:userapp/index.dart';
import 'package:userapp/login.dart';
import 'package:userapp/myprofile.dart';
import 'package:userapp/register.dart';


import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ezjgfmqprisbodrusyij.supabase.co',
    anonKey: 'sb_publishable_dcoOKwi85N6A6BGpp4wZxg_fg1a4FKk',
  );
  runApp(MainApp());
}

final supabase = Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       home:Login(), // No session
    );
  }
}

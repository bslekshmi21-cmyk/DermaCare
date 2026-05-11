import 'package:adminapp/home.dart';
import 'package:adminapp/login.dart';
import 'package:adminapp/register.dart';
import 'package:adminapp/subcate.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ezjgfmqprisbodrusyij.supabase.co',
    anonKey: 'sb_publishable_dcoOKwi85N6A6BGpp4wZxg_fg1a4FKk',
  );
  runApp(MainApp());
}
final supabase=Supabase.instance.client;

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home:Login());
  }
}

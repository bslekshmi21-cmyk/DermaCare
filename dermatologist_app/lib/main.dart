import 'dart:math';

import 'package:dermatologist_app/dermopage.dart';
import 'package:dermatologist_app/home.dart';
import 'package:dermatologist_app/login.dart';
import 'package:dermatologist_app/profile.dart';
import 'package:dermatologist_app/register.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      home: Login()
    );
  }
}

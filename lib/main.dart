import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
     WidgetsFlutterBinding.ensureInitialized();

   await Supabase.initialize(
    url: 'https://uczbdzvtawqtrthbsepb.supabase.co',
    anonKey: 'sb_publishable_6fwnh0IGv4Xp5ZDXPr5MEA_iABqjMlD',
  );
  runApp(const ProviderScope(child: MyApp()));
}
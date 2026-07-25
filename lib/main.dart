import 'package:flutter/material.dart';
import 'bootstrap/bootstrap.dart';
import 'app/app.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Bootstrap.initialize();

  runApp( MagicFarmApp());
}
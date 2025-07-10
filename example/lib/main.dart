import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const RoleBasedApp());
}

class RoleBasedApp extends StatelessWidget {
  const RoleBasedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI Guard Example',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const RoleHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

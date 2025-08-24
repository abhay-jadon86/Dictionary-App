import 'package:dictionary_app/homepage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dictionary_app/loginpage.dart';

class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  late Future<Widget> _screenToShow;

  @override
  void initState() {
    super.initState();
    _screenToShow = checkuser();
  }

  Future<Widget> checkuser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _screenToShow,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return const Scaffold(
            body: Center(child: Text("Something went wrong")),
          );
        }
      },
    );
  }
}

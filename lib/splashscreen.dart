import 'dart:async';

import 'package:dictionary_app/checkuser.dart';
import 'package:dictionary_app/homepage.dart';
import 'package:flutter/material.dart';
import 'package:dictionary_app/loginpage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() {
    return _SplashScreeenState() ;
  }

}

class _SplashScreeenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> CheckUser()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: Center(child: SizedBox.expand(

         child: Image.asset("assets/images/splashscreen2.jpg",
         fit: BoxFit.cover ,
           filterQuality: FilterQuality.high,
         )))
    );

  }
  
}
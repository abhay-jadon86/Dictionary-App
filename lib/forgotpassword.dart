import 'package:dictionary_app/uihelper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() {
    return _ForgotPasswordState();
  }
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();

  forgotpassword(String email) async {
    if (email.isEmpty) {
      uiHelper.CustomAlertBox(context, "Enter required fields!!");
    } else {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        uiHelper.CustomAlertBox(context, "Reset email sent! Check your inbox.");
      } on FirebaseAuthException catch (e) {
        uiHelper.CustomAlertBox(context, e.message ?? "An error occurred.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3A1F7A),
        iconTheme: IconThemeData(
          size: 30,
          color: Colors.white
        ),
        title: Text("Forgot Password",
        style: GoogleFonts.interTight(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.bold
        ),),
        centerTitle: true,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A7B88), Color(0xFF3A1F7A)],
            stops: [0, 1],
            begin: AlignmentDirectional(1, 0),
            end: AlignmentDirectional(-1, 0),
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            uiHelper.customTextField(emailController, "Email", Icons.email, false),
            SizedBox(height: 20,),
            uiHelper.CustomButton((){
              forgotpassword(emailController.text.toString());
              }, "Reset Password", 18)
          ],
        ),
      ),
    );
  }

}
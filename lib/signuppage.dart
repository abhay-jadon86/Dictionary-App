import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dictionary_app/uihelper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dictionary_app/homepage.dart';

class SignUpPage extends StatefulWidget{
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() {
    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignUpPage>{
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  signUp(String email, String password) async{
    if(email=="" && password==""){
      uiHelper.CustomAlertBox(context, "Enter Required Fields!!");
    }
    else {
      UserCredential? usercredential ;
      try{
        usercredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).then((value){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> HomePage()));
        });
      }
      on FirebaseAuthException catch(ex){
        return uiHelper.CustomAlertBox(context, ex.code.toString());
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Up Page",
          style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold
          ),),
        centerTitle: true,
        iconTheme: IconThemeData(
            color: Colors.white,
            size: 30
        ),
        backgroundColor: Color(0xFF3A1F7A),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A7B88), Color(0xFF3A1F7A)],
                      stops: [0, 1],
                      begin: AlignmentDirectional(1, 0),
                      end: AlignmentDirectional(-1, 0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: Color(0x33FFFFFF),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 30,
                              color: Color(0x4D000000),
                              offset: Offset(0, 15),
                            )
                          ],
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(width: 1, color: Color(0x66FFFFFF)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            uiHelper.customTextField(emailController, "Email", Icons.email, false),
                            uiHelper.customTextField(passwordController, "Password", Icons.lock, true),
                            SizedBox(height: 30),
                            uiHelper.CustomButton(() {
                              signUp(emailController.text, passwordController.text);
                            }, "Sign Up", 23),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),

    );
  }

}
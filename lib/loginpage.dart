import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'uihelper.dart';
import 'signuppage.dart';
import 'package:dictionary_app/homepage.dart';
import 'package:dictionary_app/forgotpassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  login(String email, String password) async{
    if(email==""&& password==""){
      uiHelper.CustomAlertBox(context, "Enter required fields!!");
    }
    else {
      UserCredential? usercredintial;
      try {
        usercredintial = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, password: password).then((value) {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> HomePage()));
        });
      }
      on FirebaseAuthException catch (ex) {
        return uiHelper.CustomAlertBox(context, ex.code.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A7B88), Color(0xFF3A1F7A)],
            stops: [0, 1],
            begin: AlignmentDirectional(1, 0),
            end: AlignmentDirectional(-1, 0),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.09),
              Container(
                height: screenHeight * 0.15,
                width: screenHeight * 0.15,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: Image.asset(
                  "assets/images/Logo_dictionary.png",
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20,32,20,32),
                child: Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                      maxHeight: screenHeight*0.7
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x33FFFFFF),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 30,
                        color: Color(0x4D000000),
                        offset: Offset(0, 15),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(width: 1, color: const Color(0x66FFFFFF)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.04,
                      horizontal: screenWidth * 0.04,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome Back,\n Explorer!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.interTight(
                              height: 1.1,
                              fontSize: screenWidth * 0.08,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            "Ready to embark your next linguistic adventure?",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.interTight(
                              fontSize: screenWidth * 0.045,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          uiHelper.customTextField(
                            emailController,
                            "Email",
                            Icons.email,
                            false,
                          ),
                          uiHelper.customTextField(
                            passwordController,
                            "Password",
                            Icons.lock,
                            true,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          uiHelper.CustomButton(() {
                            login(emailController.text.toString(), passwordController.text.toString());
                          }, "Login", 23),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: GoogleFonts.interTight(
                                  fontSize: screenWidth * 0.04,
                                  color: Colors.white,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                                  );
                                },
                                child: Text(
                                  "Sign Up",
                                  style: GoogleFonts.interTight(
                                    fontSize: screenWidth * 0.05,
                                    color: const Color(0xFF3A1F7A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          TextButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> ForgotPassword()));
                          }, child: Text("Forgot Password??",
                            style: GoogleFonts.interTight(
                                fontWeight: FontWeight.w500,
                                fontSize: screenWidth * 0.045,
                                color: Color(0xFF3A1F7A)
                            ),
                          ))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

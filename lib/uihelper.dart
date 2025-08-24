import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class uiHelper {
  static customTextField(TextEditingController controller, String Text, IconData icondata, bool toHide){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: toHide,
        decoration: InputDecoration(
          filled: true,
            fillColor: Colors.white,
            hintText: Text,
            prefixIcon: Icon(icondata, color: Color(0xFF1A7B88)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
            )
        ),
      ),
    );
  }

  static CustomButton(VoidCallback voidcallback, String text, double fs){
    return SizedBox(
      height: 50,
      width: 200,
      child: ElevatedButton(
          onPressed: voidcallback,

          style: ElevatedButton.styleFrom(
            side: BorderSide(
              color: Color(0xFF1A7B88),
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            ),
            elevation: 8,
              backgroundColor: Color(0xFF3A1F7A),
          ),
          child: Text(text,style: GoogleFonts.interTight(
              color: Colors.white,
              fontSize: fs,
          fontWeight: FontWeight.bold), )),
    );
  }

  static CustomAlertBox(BuildContext context, String text){
    return showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text(text),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text("OK"))
        ],
      );
    });
  }
}
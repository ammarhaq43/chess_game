import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 6),
          () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 220),
              child: Icon(Icons.fastfood_rounded,size: 70,),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text('Food Hygiene Rating',style: GoogleFonts.pacifico(
                  textStyle: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500
                  )
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 280),
              child: CircularProgressIndicator(
                color: Colors.black,
                backgroundColor: Colors.yellow,
                strokeWidth: 5,
              ),
            )
          ],
        ),
      ),
    );
  }
}

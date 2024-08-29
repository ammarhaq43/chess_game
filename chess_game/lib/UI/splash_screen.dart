import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:chess_game/UI/game_board.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    _navigateToLogin();
  }

  void _startAnimation() {
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });
  }

  void _navigateToLogin() {
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GameBoard()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[600],
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: _scale,
                  duration: const Duration(seconds: 2),
                  child: AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(seconds: 2),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                        child: Center(
                          child: Text('Pawn to King', style: GoogleFonts.breeSerif(
                            fontSize: 50,
                            color: Colors.black
                          ),),
                        )
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


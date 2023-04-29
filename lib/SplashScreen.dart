import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/opening_screen.dart';



import 'screens/signin_screen.dart';
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final auth = FirebaseAuth.instance;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    //show screen for 2 secs
    _timer = Timer(const Duration(seconds: 2), () {
      //if user is authenticated then move to AuthPage else move to MainActivityPage
      if (auth.currentUser == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => OpeningScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // cancel the timer when the screen is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlutterLogo(
          size: 200,
        ),
      ),
    );
  }
}
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
  @override
  Widget build(BuildContext context) {
    //show screen for 2 secs
    Future.delayed(const Duration(seconds: 2), () {
      //if user is authenticated then move to AuthPage else move to MainActivityPage
      if (auth.currentUser == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) =>  OpeningScreen()),
        );
      }

    });

    return Scaffold(
      body: Center(
          child: FlutterLogo(
            size: 100,
          )),
    );
  }
}
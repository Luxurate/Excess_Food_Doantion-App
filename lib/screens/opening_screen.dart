import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

import 'signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:fooddonation/reusable_widgets/reusable_widget.dart';
import 'package:fooddonation/screens/signin_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'DonateScreen.dart';
import 'ItemScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';

class OpeningScreen extends StatefulWidget {
  @override
  _OpeningScreenState createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  double heartButtonSize = 100.0;
  double searchButtonSize = 100.0;

  void _onHeartButtonPressed() {
    Future.delayed(const Duration(milliseconds: 100), () {
    setState(() {
      heartButtonSize = 100.0;
      searchButtonSize = 10.0;
    });

    Future.delayed(const Duration(milliseconds: 360), () {
      Navigator.of(context).push(_createRoute());
      setState(() {
        heartButtonSize = 100.0;
        searchButtonSize = 100.0;
      });

      // Perform navigation here

      Fluttertoast.showToast(
        msg: "Location will be Fetched...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.amber,
        textColor: Colors.black,
        fontSize: 19.0,
      );
    });
    });
  }

  void _onSearchButtonPressed() {

    setState(() {
      searchButtonSize = 100.0;
      heartButtonSize = 10.0;
      // Set the size of the other icon to be smaller
    });

    Future.delayed(const Duration(milliseconds: 360), () {
      Navigator.of(context).push(_createRoutec());
      setState(() {
        searchButtonSize = 100.0;
        heartButtonSize = 100.0;
      });


      // Perform navigation here

    });


  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Myss App',
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(
              height: 200,
            ),
            const Text(
              'Want To Share Food?',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'SimpleSans',
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Choose any one',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Schyler',
                fontSize: 12.0,
              ),
            ),
            const SizedBox(height: 88.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: heartButtonSize,
                  height: heartButtonSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber,
                  ),
                  child: GestureDetector(
                    onTap: _onHeartButtonPressed,
                    child: IconButton(
                      icon: Image.asset('assets/heart.png'),
                      color: Colors.white,
                      onPressed: null,
                    ),
                  ),
                ),
                const SizedBox(width: 49.0),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: searchButtonSize,
                  height: searchButtonSize,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber,
                  ),
                  child: GestureDetector(
                    onTap: _onSearchButtonPressed,
                    child: IconButton(
                      icon: Image.asset('assets/search.png'),
                      onPressed: null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Image.asset(
                'assets/barb1.png',
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
                width: 300,
                height: 50,
              ),
            ),
            const SizedBox(
              height: 1,
            ),
            Container(
              width: 70.0,
              height: 70.0,
              child: IconButton(
                icon: const Icon(Icons.exit_to_app_sharp),
                color: Colors.black,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const MyApp(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: animation,
        alignment: Alignment.bottomCenter,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 700),
  );
}


Route _createRoutec() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ItemsScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: animation,
        alignment: Alignment.bottomCenter,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 700),
  );
}


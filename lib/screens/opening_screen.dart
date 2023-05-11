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

class OpeningScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 200,
            ),
            Text(
              'Want To Share Food?',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: 'SimpleSans',
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Choose any one',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: 'Schyler',
                fontSize: 12.0,
              ),
            ),
            SizedBox(height: 78.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber,
                  ),
                  child: IconButton(
                    icon: Image.asset('assets/heart.png'),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.of(context).push(_createRoute());
                      Fluttertoast.showToast(
                        msg: "Fetching Your Location..........",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 5,
                        backgroundColor: Colors.amber,
                        textColor: Colors.black,
                        fontSize: 20.0,
                      );

                    },
                  ),
                ),
                SizedBox(width: 16.0),
                Container(
                  width: 140.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber,
                  ),
                  child: IconButton(
                    icon: Image.asset('assets/search.png'),
                    onPressed: () {
                      Navigator.of(context).push(_createRoutec());

                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: Image.asset(
                'assets/barb1.png',
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
                width: 300,
                height: 50,
              ),
            ),
            SizedBox(
              height: 1,
            ),
            Container(
              width: 70.0,
              height: 70.0,
              child: IconButton(
                icon: Icon(Icons.exit_to_app_sharp),
                color: Colors.black,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SignInScreen(),
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
      const begin = Offset(1.4, 0.1);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Route _createRoutec() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ItemsScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.4, 0.1);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      final offsetAnimation = animation.drive(tween);
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

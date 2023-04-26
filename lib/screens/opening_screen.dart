import 'package:flutter/material.dart';
import 'package:fooddonation/screens/signin_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'DonateScreen.dart';
import 'ItemScreen.dart';

class OpeningScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/login_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreen,
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 30),
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text('Donator'),
                  onPressed: () {
                    Navigator.of(context).push(_createRoute());
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.indigo,
                    padding: EdgeInsets.symmetric(horizontal: 83, vertical: 30),
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text('Seeker'),
                  onPressed: () {

                    Navigator.of(context).push(_createRoutec());
                  },
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 40),
                  SizedBox(width: 40),
                ],
              ),
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (context) => SignInScreen()));
                  // Do something when the user taps the logout icon
                },
              ),
            ],
          ),
          elevation: 3,
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
    pageBuilder: (context, animation, secondaryAnimation) =>  ItemsScreen(),
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
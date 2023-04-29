import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fooddonation/reusable_widgets/reusable_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'reset_password.dart';
import 'signup_screen.dart';
import 'opening_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
        body: Column(
        children: [
        Expanded(
        child: Stack(
        children: [
        Positioned.fill(
        child: Image.asset(
        'assets/login_bg.png', // replace with your image path
        fit: BoxFit.cover,
    ),
    ),
    Positioned.fill(
    child: Container(
    alignment: Alignment.topCenter,
    padding: EdgeInsets.only(top: 100),
    child: ShaderMask(
    shaderCallback: (bounds) =>
    LinearGradient(
    colors: [Colors.orange, Colors.deepOrangeAccent],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 1.0],
    ).createShader(bounds),
    child: Text(
    'DONATISTIC',
    style: TextStyle(
    color: Colors.white,
    fontFamily: 'Schyler',
    fontSize: 50,
    fontWeight: FontWeight.bold,
    shadows: [
    Shadow(
    blurRadius: 10,
    color: Colors.black,
    offset: Offset(2, 2),
    ),
    ],
    ),
    ),
    ),
    ),
    ),
    Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    reusableTextField(
    "Enter E-mail",
    Icons.person_outline,
    false,
    _emailTextController,
    ),
    const SizedBox(height: 20),
    reusableTextField(
    "Enter Password",
    Icons.lock_outline,
    true,
    _passwordTextController,
    ),
    const SizedBox(height: 5),
    forgetPassword(context),
    firebaseUIButton(context, "Sign In", () {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
    email: _emailTextController.text,
    password: _passwordTextController.text)
        .then((value) {
    Fluttertoast.showToast(
    msg: "Logged In !!",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.lightGreenAccent,
    textColor: Colors.white,
                            fontSize: 16.0);
                        //print(error);
                      });
                    }),
                    signUpOption(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'No Account?',
          style: GoogleFonts.lato(
            textStyle: TextStyle(color: Colors.white60, letterSpacing: .5),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: const Text(
            " Sign Up",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: Text(
          'Forgot Password?',
          style: GoogleFonts.lato(
            textStyle: TextStyle(color: Colors.white70, letterSpacing: .5),
          ),
          textAlign: TextAlign.right,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              final TextEditingController _emailTextController =
              TextEditingController();
              return AlertDialog(
                title: Text("Reset Password"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        "Enter your registered email address to receive password reset instructions"),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailTextController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Email address cannot be empty";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text("Send"),
                    onPressed: () async {
                      if (_emailTextController.text.isNotEmpty) {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(
                            email: _emailTextController.text)
                            .then(
                              (_) {
                            Navigator.of(context).pop();
                            showAlertDialog(context, "Reset Password",
                                "Password reset instructions have been sent to your email.");
                          },
                        ).onError(
                              (error, stackTrace) {
                            showAlertDialog(context, "Error", error.toString());
                          },
                        );
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

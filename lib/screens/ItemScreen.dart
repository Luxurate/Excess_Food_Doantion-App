import 'dart:math';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';



class ItemsScreen extends StatefulWidget {
  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    ItemsScreen(),
    //ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        elevation: 2,
        title: Text(
          'What Do You Seek?',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'SimpleSans',
            fontSize: 20,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Donatedpage()));

            },
          ),
        ],

      ),

        body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('items').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something has gone wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 0,
                mainAxisSpacing: 7,
                childAspectRatio:1.5,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        child: ItemDetailScreen(data),
                        type: PageTransitionType.theme,
                        alignment: Alignment.bottomCenter,
                        duration: Duration(milliseconds: 1000),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white54,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.7),
                          spreadRadius: 3,
                          blurRadius: 30,
                          offset: Offset(5, 11),
                        ),
                      ],
                      // Added edge insets
                      border: Border.all(
                        color: Colors.amber,
                        width: 4,
                      ),
                    ),


                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(14)
                        , bottom: Radius.circular(1)),
                        child: Padding(
                          padding: EdgeInsets.only(top: 0),

                          child: Image.network(
                            data['imageUrl'],
                            fit: BoxFit.cover,
                            height: 410,
                            width: 380,
                          ),
                        ),
                      ),

                      Positioned(
                top: 6,
                left: 8,
                child: Container(
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.redAccent.withOpacity(1),
                ),
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                child: Text(
                'Qty  :  ${data['quantity']}',
                style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontFamily: 'SimpleSans',
                ),
                ),
                ),
                ),
                      Positioned(
                        top: 175,
                        left: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white54.withOpacity(1),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                          child: Text(
                            ' ${data['itemName']}',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontFamily: 'SimpleSans',
                            ),
                          ),
                        ),
                      ),

                ],
                ),
                        ),
                        //this is for the image in the frame==================================================
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 98,right: 8, top: 0, bottom: 0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete_outlined),
                                color: Colors.red,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(

                                        title: Text("Confirm Delete"),
                                        content: Text("Are you sure you want to delete this item?"),
                                        actions: [
                                          TextButton(
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text("Delete"),
                                            onPressed: () {
                                              String currentUserId = FirebaseAuth.instance.currentUser!.uid;
                                              print('Current user ID: $currentUserId');
                                              _deleteImage(snapshot.data!.docs[index].id);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),


                              IconButton(
                                icon: Icon(Icons.info),
                                color: Colors.blue,
                                onPressed: () {
                                  _showInformation(snapshot.data!.docs[index].id);

                                  // Perform edit action here
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.handshake_outlined),
                                color: Colors.orange,
                                onPressed: () async {
                                  bool donated = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(


                                        title: Text('Do you want to Book this Item?',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'SimpleSans',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        actions: <Widget>[

                                          TextButton(
                                            child: Text('No'),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Yes'),
                                            onPressed: () {

                                              Navigator.of(context).pop(true);
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (donated == true) {
                                    _handImage(snapshot.data!.docs[index].id);
                                  }
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                color: Colors.purple,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      TextEditingController controller = TextEditingController();

                                      return AlertDialog(
                                        title: Text('Edit Quantity'),
                                        content: TextField(
                                          controller: controller,
                                          keyboardType: TextInputType.number,
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Save'),
                                            onPressed: () {
                                              String newQuantity = controller.text;
                                              String currentUser = FirebaseAuth.instance.currentUser!.uid;
                                              _editQuantity(snapshot.data!.docs[index].id, newQuantity, currentUser);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),


    );
  }
  void _editQuantity(String docId, String newQuantity, String currentUser) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    final doc = await FirebaseFirestore.instance.collection('items').doc(docId).get();
    final ownerId = doc['uid'];

    if (currentUser != null && ownerId == currentUser.uid) {
      await FirebaseFirestore.instance.collection('items').doc(docId).update({'quantity': newQuantity});
      Fluttertoast.showToast(
        msg: "Successfully Updated The Quantity!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.lightGreenAccent,
        textColor: Colors.black,
        fontSize: 16.0,
      );
    } else {
      print('Current user does not have permission to edit the quantity of this item.');
      Fluttertoast.showToast(
        msg: "You are not authorized to edit the quantity!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }


  void _onItemTappeds(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Donatedpage()),
        );
      }
    });
  }

  void _deleteImage(String docId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    final doc =
    await FirebaseFirestore.instance.collection('items').doc(docId).get();
    final ownerId = doc['uid'];
    print(docId);
    if (currentUser != null && ownerId == currentUser.uid) {
      await FirebaseFirestore.instance.collection('items').doc(docId).delete();
      Fluttertoast.showToast(
          msg: "Successfully Deleted The Post!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.lightGreenAccent,
          textColor: Colors.black,
          fontSize: 16.0);
    } else {
      print('Current user does not have permission to delete this item.');
      Fluttertoast.showToast(
          msg: "You are not authorized to delete this!!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}

void _handImage(String docId) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  final doc = await FirebaseFirestore.instance.collection('items')
      .doc(docId)
      .get();
  final ownerId = doc['uid'];

  if (currentUser != null && ownerId == currentUser.uid) {
    // Copy the document to the "donations" collection
    await FirebaseFirestore.instance.collection('donations').doc(docId).set(
        doc.data()!);

    // Delete the document from the "items" collection
    await FirebaseFirestore.instance.collection('items').doc(docId).delete();
    Fluttertoast.showToast(
        msg: "Successfully Added the Item to Donated Collection!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.lightGreenAccent,
        textColor: Colors.white,
        fontSize: 16.0);
  } else {
    print('This is not Your Item!!');
    Fluttertoast.showToast(
        msg: "Please Call the Donator to Book this Item!!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 10,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

}



void _showInformation(String docId) async {
  final doc = await FirebaseFirestore.instance.collection('items').doc(docId).get();
  final username = doc['username'];
  Fluttertoast.showToast(
    msg: "Donated by: $username",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey[600],
    textColor: Colors.white,
    fontSize: 16.0,
  );
}


class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  ItemDetailScreen(this.data);

  String? get itemDocId => null;

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late DocumentReference _documentRefernce;
  int _currentIndex = 0;

  String? get itemId => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.data['itemName'],
          style: TextStyle(
            height: 1,
            wordSpacing: 4,
            fontFamily: 'Schyler',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.amber,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Image.network(
                widget.data['imageUrl'],
                width: 600,
                height: 450,
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(height: 1),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(80),
              color: Colors.red.withOpacity(0.2),
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Text(
              'Quantity: ${widget.data['quantity']}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontFamily: 'JoseBold',
              ),
            ),
          ),
          SizedBox(height: 1),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Text(
              'Phone: ${widget.data['phone']}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontFamily: 'SimpleSans',
              ),
            ),
          ),
          SizedBox(height: 1),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Text(
              'Pickup Time: ${widget.data['time']}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontFamily: 'SimpleSans',
              ),
            ),
          ),
          SizedBox(height: 1),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Text(
              'Address: ${widget.data['address']}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontFamily: 'SimpleSans',
              ),
            ),
          ),
          Spacer(), // Add a spacer to push the chat button to the bottom
          GestureDetector(
            onTap: () {
              // Add your functionality here for when the chat button is pressed
            },
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.call),
                  label: Text(''),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    minimumSize: Size.zero,
                  ),
                  onPressed: () async {
                    final phone = widget.data['phone'].toString();
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Confirm Phone Call'),
                        content: Text('Are you sure you want to call $phone?'),
                        actions: [
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: Text('Call'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      final result = await FlutterPhoneDirectCaller.callNumber(phone);
                      if (!result!) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Failed to make phone call.'),
                        ));
                      }
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class Donatedpage extends StatefulWidget {
  @override
  _DonatedpageState createState() => _DonatedpageState();
}

class _DonatedpageState extends State<Donatedpage> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    Donatedpage(),
    //ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        elevation: 2,
        title: Text(
          ' Booked / Donated ',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'SimpleSans',
            fontSize: 20,
          ),
        ),

      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 15),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('donations').snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {

                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.7),
                          spreadRadius: 3,
                          blurRadius: 10,
                          offset: Offset(0, 9),
                        ),
                      ],
                      // Added edge insets
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),


                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(0)
                                    , bottom: Radius.circular(9)),
                                child: Padding(
                                  padding: EdgeInsets.only(top: 4),

                                  child: Image.network(
                                    data['imageUrl'],
                                    fit: BoxFit.cover,
                                    height: 410,
                                    width: 380,
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(90),
                                    color: Colors.white.withOpacity(1),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 1, horizontal: 8),
                                  child: Text(
                                    'Qty  :  ${data['quantity']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                      fontFamily: 'SimpleSans',
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 146,
                                left: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: Colors.white.withOpacity(1),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 1, horizontal: 8),
                                  child: Text(
                                    ' ${data['itemName']}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontFamily: 'SimpleSans',
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.only(
                              right: 8, top: 1, bottom: 0),
                          child: Row(
                            children: [






                            ],
                          ),
                        ),


                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }}
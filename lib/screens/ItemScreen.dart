import 'dart:math';

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
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'DONATISTIC',
          style: TextStyle(
            color: Colors.deepOrangeAccent,
            fontFamily: 'Schyler',
            fontSize: 25,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 15),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('items').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                childAspectRatio:1.3,
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
                        duration: Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
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
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),


                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Stack(
                    children: [
                    ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    data['imageUrl'],
                    fit: BoxFit.fill,
                    height: 400,
                    width: 389,
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
                padding: EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                child: Text(
                'Qty  :  ${data['quantity']}',
                style: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontFamily: 'Schyler',
                ),
                ),
                ),
                ),
                      Positioned(
                        top: 200,
                        left: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.white.withOpacity(1),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 1, horizontal: 8),
                          child: Text(
                            ' ${data['itemName']}',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontFamily: 'Schyler',
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
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [



                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 8, top: 1, bottom: 0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete_forever),
                                color: Colors.black,
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
                                color: Colors.black,
                                onPressed: () {
                                  _showInformation(snapshot.data!.docs[index].id);

                                  // Perform edit action here
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.share),
                                color: Colors.black,
                                onPressed: () {
                                  // Perform share action here
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
          textColor: Colors.white,
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
void _showInformation(String docId) async {
  final doc = await FirebaseFirestore.instance.collection('items').doc(docId).get();
  final username = doc['username'];
  Fluttertoast.showToast(
    msg: "Uploaded by: $username",
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

  @override
  _ItemDetailScreenState createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late DocumentReference _documentRefernce;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.lightBlue,

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
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              widget.data['imageUrl'],
              width: 412,
              height: 330,
              fit: BoxFit.fill,

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
                fontFamily: 'Schyler',
              ),
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Text(
              'Phone: ${widget.data['phone']}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontFamily: 'Schyler',
              ),
            ),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Text(
              'Time: ${widget.data['time']}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontFamily: 'Schyler',
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Text(
              'Address: ${widget.data['address']}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontFamily: 'Schyler',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

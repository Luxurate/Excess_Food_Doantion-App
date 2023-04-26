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
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
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
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2,
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
                        type: PageTransitionType.size,
                        alignment: Alignment.center,
                        duration: Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: GridTile(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: double.infinity,
                        child: Image.network(
                          data['imageUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    footer: GridTileBar(
                      backgroundColor: Colors.black.withOpacity(0.0),
                      title: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black.withOpacity(0.6),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Text(
                          data['itemName'],
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'GodshineSansBold',
                            color: Colors.white,
                          ),
                        ),
                      ),
                      subtitle: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(1),
                              spreadRadius: 1,
                              blurRadius: 50,
                              offset: Offset(0, 9),
                            ),
                          ],
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Text(
                          'Quantity: ${data['quantity']}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                            fontFamily: 'Schyler',
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          String currentUserId =
                              FirebaseAuth.instance.currentUser!.uid;
                          print('Current user ID: $currentUserId');
                          _deleteImage(snapshot.data!.docs[index].id);
                        },
                      ),
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
          msg: "User is not authorized to delete this image",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.data['itemName'],
          style: TextStyle(
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
            borderRadius: BorderRadius.circular(0),
            child: Image.network(
              widget.data['imageUrl'],
              width: 410,
              height: 330,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 1),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black.withOpacity(0.9),
            ),
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
            child: Text(
              'Quantity: ${widget.data['quantity']}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'Schyler',
              ),
            ),
          ),
          SizedBox(height: 1),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black.withOpacity(0.9),
            ),
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
            child: Text(
              'Phone   :     ${widget.data['phone']}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'Schyler',
              ),
            ),
          ),
          SizedBox(height: 1),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black.withOpacity(0.9),
            ),
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 20),
            child: Text(
              'Time    :       ${widget.data['time']}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'Schyler',
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black.withOpacity(0.9),
            ),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text(
              'Address  :        ${widget.data['address']}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

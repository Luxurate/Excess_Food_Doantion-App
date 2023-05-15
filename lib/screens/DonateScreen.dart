import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'opening_screen.dart';
import '../common/theme_helper.dart';
import '';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Firebase Storage Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const UploadingImageToFirebaseStorage(),
    );
  }
}

final Color yellow = const Color(0xfadab9ef);
final Color orange = const Color(0xfcf1efff);

class UploadingImageToFirebaseStorage extends StatefulWidget {
  const UploadingImageToFirebaseStorage({Key? key}) : super(key: key);

  @override
  _UploadingImageToFirebaseStorageState createState() =>
      _UploadingImageToFirebaseStorageState();
}

class _UploadingImageToFirebaseStorageState
    extends State<UploadingImageToFirebaseStorage> {
  File? _image;

  ///NOTE: Only supported on Android & iOS
  ///Needs image_picker plugin {https://pub.dev/packages/image_picker}
  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }


  /*Future<void> pickImage() async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }*/
  Future<void> uploadImageToFirebase(BuildContext context, String userName,String itemName,
      int quantity, int phone, String address, String time) async {
    if (_image == null) {
      return;
    }

    // Show loading indicator
    final loadingGif = Image.asset(
      'assets/loadingif.gif',
      width: 1000.0,
      height: 1000.0,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Container(
              color: Colors.black, // set the background color to black with 70% opacity
            ),
            Center(
              child: loadingGif,
            ),
          ],
        );
      },
    );



    try {
      String fileName = basename(_image!.path);
      Reference firebaseStorageRef =
      FirebaseStorage.instance.ref().child('uploads/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(_image!);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference itemsCollection = firestore.collection('items');

      // Get the current user's ID
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Add the item data to the items collection
      await itemsCollection.add({
        'username' : userName,
        'itemName': itemName,
        'quantity': quantity,
        'phone': phone,
        'address': address,
        'time': time,
        'imageUrl': downloadUrl,
        'uid': uid, // add the user's ID to the item data
      });


      // Show success message
      Fluttertoast.showToast(
        msg: "Uploaded successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Add the user's data to the users collection
      CollectionReference usersCollection = firestore.collection('users');
      await usersCollection.doc(uid).set({
        'name': FirebaseAuth.instance.currentUser!.displayName,
        'email': FirebaseAuth.instance.currentUser!.email,
        'imageUrl': FirebaseAuth.instance.currentUser!.photoURL,
      });

      // Hide loading indicator after 4 seconds
      Timer(Duration(seconds: 2), () {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => OpeningScreen()),
              (route) => false,
        );
      });

      print("Done: $downloadUrl");
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context, rootNavigator: true).pop();

      // Show error message
      Fluttertoast.showToast(
        msg: "Error uploading image: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }


  @override

  String  _currentLocation ='';
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0];
      setState(() {
        _currentLocation =
        '${placemark.thoroughfare},${placemark.subThoroughfare},${placemark.street},${placemark.name},${placemark.subLocality},${placemark.locality},${placemark.postalCode}, ${placemark.administrativeArea}, ${placemark.country}';
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _currentLocation = 'Error getting location';
      });
    }
  }
  void _uploadLocation() async {
    try {
      await FirebaseFirestore.instance
          .collection('items')
          .add({'address': _currentLocation});
      print('Location Has Been Uploaded');
    } catch (e) {
      print('Error uploading location: $e');
    }
  }

  final _itemNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _timeController = TextEditingController();
  final _userNameController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          'Donation Screen',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'SimpleSans',
          ),
        ),

      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: Image.file(
                  _image!,
                  width: 300,
                  height: 400,
                ),
              ),
            SizedBox(height: 16),
            TextField(
              controller: _userNameController,
              decoration: ThemeHelper().textInputDecoration(
                'Username', ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-z, A-Z]')),

                ],

            ),
            SizedBox(height: 16),
            TextField(
              controller: _itemNameController,
              decoration: ThemeHelper().textInputDecoration(
                'Item Name',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: ThemeHelper().textInputDecoration(
                'Quantity',

              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),

              ],
            ),
            SizedBox(height: 16),
    TextField(
    controller: _phoneController,
    keyboardType: TextInputType.phone,
    decoration: ThemeHelper().textInputDecoration('Phone Number'),
    inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
    LengthLimitingTextInputFormatter(10),
    ],
    ),


    SizedBox(height: 16),
            TextField(

              decoration: ThemeHelper().textInputDecoration(
                'Address',


              ),
              controller: TextEditingController(text: _currentLocation),
              readOnly: false,
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (selectedDate != null) {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                  );
                  if (selectedTime != null) {
                    setState(() {
                      _timeController.text =
                          DateFormat('yyyy-MM-dd').format(selectedDate) +
                              ' ' +
                              selectedTime.format(context).toString();
                    });
                  } else {
                    // User canceled time selection, clear text field
                    setState(() {
                      _timeController.clear();
                    });
                  }
                } else {
                  // User canceled date selection, clear text field
                  setState(() {
                    _timeController.clear();
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: _timeController,
                  decoration: ThemeHelper().textInputDecoration('Pickup Date and Time'),
                ),
              ),
            ),

            SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: 80.0,
                height: 86.0,
                child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) =>
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: Icon(Icons.camera),

                                title: Text(
                                  'Take A Picture...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontFamily: 'SimpleSans',
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.photo_library),
                                title: Text(
                                  'Choose From Gallery...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontFamily: 'SimpleSans',
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                            ],
                          ),
                    );
                  },
                  icon: Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: 65.0,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ThemeHelper().buttonStyle(),

              onPressed: () {
                if (_image == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select an image')),
                  );
                  return;
                }

                uploadImageToFirebase(
                  context,
                  _userNameController.text,
                  _itemNameController.text,
                  int.parse(_quantityController.text),
                  int.parse(_phoneController.text),
                  _addressController.text = _currentLocation,
                  _timeController.text,
                );

              },
              child: Text(
                '        Upload        ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'SimpleSans',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




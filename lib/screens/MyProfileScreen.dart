import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User _currentUser;
  late DocumentSnapshot _userProfileSnapshot;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _imageFile;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _currentUser = FirebaseAuth.instance.currentUser!;
    _userProfileSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser.uid)
        .get();

    setState(() {
      _nameController.text = _userProfileSnapshot['name'];
      _emailController.text = _userProfileSnapshot['email'];
      _phoneController.text = _userProfileSnapshot['phone'];
    });
  }

  Future<void> _selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      final userId = _currentUser.uid;
      final storageRef = FirebaseStorage.instance.ref().child('profile_pictures/$userId.jpg');
      await storageRef.putFile(_imageFile!);

      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'imageUrl': imageUrl});

      await _getCurrentUser();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile picture uploaded successfully!'),
        ),
      );
    } catch (e) {
      print('Error uploading profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload . Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = _userProfileSnapshot.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.purple,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SimpleSans',
            fontSize: 20,
          ),
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Edit Profile'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                          ),
                        ),
                        TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone',
                          ),
                        ),
                      ],
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
                          String newName = _nameController.text;
                          String newEmail = _emailController.text;
                          String newPhone = _phoneController.text;
                          String currentUserId = _currentUser.uid;

                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUserId)
                              .update({
                            'name': newName,
                            'email': newEmail,
                            'phone': newPhone,
                          });

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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: GestureDetector(
                onTap: _selectImage,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CircleAvatar(
                      radius: 80.0,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : userProfile['imageUrl'] != null
                          ? NetworkImage(userProfile['imageUrl']) as ImageProvider
                          : AssetImage('assets/default_profile_image.png'),
                    ),
                    IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: _selectImage,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Your Profile Picture'),
            ),

            SizedBox(height: 16.0),
            Text(
              userProfile['name'],
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              userProfile['email'],
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Text(
              userProfile['phone'],
              style: TextStyle(fontSize: 16.0),
            ),

          ],
        ),
      ),
    );
  }
}

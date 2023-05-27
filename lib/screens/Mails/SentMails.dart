import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SentMaills extends StatefulWidget {
  @override
  _SentMaillsState createState() => _SentMaillsState();
}

class _SentMaillsState extends State<SentMaills> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _chatsCollection = FirebaseFirestore.instance.collection('chats');
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  String? _currentUserEmail;
  String? _selectedRecipientEmail;

  @override
  void initState() {
    super.initState();
    _getCurrentUserEmail().then((_) {
      // setState to trigger the rebuild after retrieving the current user email
      setState(() {});
    });
  }

  Future<void> _getCurrentUserEmail() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      _currentUserEmail = userData['email'] as String?;
      print(_currentUserEmail);
    } else {
      // User is not logged in or user document not found
      _currentUserEmail = 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sent Mails'),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.0),
          Text(
            'Current User Email: ${_currentUserEmail ?? 'Unknown'}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatsCollection
                  .where('sender', isEqualTo:  _currentUserEmail)
                  .where('receiver', isEqualTo: _selectedRecipientEmail)

                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageData = messages[index].data() as Map<String, dynamic>;
                      final sender = messageData['sender'] as String?;
                      final receiver = messageData['receiver'] as String?;
                      final message = messageData['message'] as String?;

                      return ListTile(
                        title: Text(message ?? ''),
                        subtitle: Text(
                          'From: $sender\nTo: $receiver',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _selectedRecipientEmail != null ? _sendMessage : null,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Selected Recipient: ${_selectedRecipientEmail ?? 'None'}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: _selectRecipient,
            child: Text('Select Recipient'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectRecipient() async {
    final QuerySnapshot snapshot = await _usersCollection.get();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Recipient'),
          content: SingleChildScrollView(
            child: Column(
              children: snapshot.docs.map((DocumentSnapshot document) {
                final userData = document.data() as Map<String, dynamic>;
                final email = userData['email'] as String?;

                return ListTile(
                  title: Text(email ?? ''),
                  onTap: () {
                    Navigator.pop(context, email);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    ).then((selectedEmail) {
      if (selectedEmail != null) {
        setState(() {
          _selectedRecipientEmail = selectedEmail;
        });
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      try {
        await _chatsCollection.add({
          'sender': _currentUserEmail,
          'receiver': _selectedRecipientEmail,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }
}

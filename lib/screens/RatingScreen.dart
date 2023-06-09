import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({Key? key}) : super(key: key);

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _rating = 0;
  String _feedback = '';
  late String _userEmail;
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _getUserEmail();
  }

  void _getUserEmail() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _userEmail = currentUser.email ?? '';
      });
    }
  }

  void _setRating(int rating) {
    setState(() {
      _rating = rating;
    });
    _animationController.forward(from: 0);
  }

  void _submitFeedback() {
    FirebaseFirestore.instance.collection('ratings').add({
      'rating': _rating,
      'feedback': _feedback,
      'userEmail': _userEmail,
    }).then((value) {
      print('Feedback submitted');
      setState(() {
        _rating = 0;
        _feedback = '';
      });
      _feedbackController.clear(); // Clear the feedback text field
    }).catchError((error) {
      print('Failed to submit feedback: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rating Page'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: $_userEmail',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Rate the app:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(5, (index) {
                final starColor = index < _rating ? Colors.yellow : Colors.grey;
                return IconButton(
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.add_event,
                    color: starColor,
                    progress: _animationController,
                  ),
                  onPressed: () => _setRating(index + 1),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              'Write your feedback:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.purple, width: 1),
              ),
              child: TextField(
                controller: _feedbackController, // Feedback text field controller
                onChanged: (value) {
                  setState(() {
                    _feedback = value;
                  });
                },
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter your feedback here',
                  contentPadding: const EdgeInsets.all(10),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitFeedback,
                child: Text('Submit Feedback'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ratings:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('ratings').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final ratings = snapshot.data?.docs ?? [];

                  return ListView.builder(
                    itemCount: ratings.length,
                    itemBuilder: (context, index) {
                      final ratingData = ratings[index].data() as Map<String, dynamic>;
                      final rating = ratingData['rating'];
                      final feedback = ratingData['feedback'];
                      final userEmail = ratingData['userEmail'];

                      return ListTile(
                        title: Text('Rating: $rating'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Feedback: $feedback'),
                            Text('User: $userEmail'),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _feedbackController.dispose(); // Dispose the feedback text field controller
    super.dispose();
  }
}

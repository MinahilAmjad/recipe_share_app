import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackScreen extends StatefulWidget {
  FeedbackScreen({Key? key}) : super(key: key);

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController feedbackController = TextEditingController();

// save feedback
  Future<void> _submitFeedback(String feedback) async {
    try {
      CollectionReference feedbackCollection =
          FirebaseFirestore.instance.collection('feedback');

      // Add  feedback to Firestore
      await feedbackCollection.add({
        'feedback': feedback,
        'timestamp': DateTime.now(),
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Feedback submitted successfully\n Thanks for your feedback')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit feedback: $error')),
      );
    }
  }

  @override
  void dispose() {
    feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 242, 240, 240),
        title: Text('Feedback'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Enter your feedback',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _submitFeedback(feedbackController.text);
              },
              child: Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}

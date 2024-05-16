import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RecipeCommentsScreen extends StatefulWidget {
  final String recipientId;

  const RecipeCommentsScreen({Key? key, required this.recipientId})
      : super(key: key);

  @override
  _RecipeCommentsScreenState createState() => _RecipeCommentsScreenState();
}

class _RecipeCommentsScreenState extends State<RecipeCommentsScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('senderId',
                      isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .where('recipientId', isEqualTo: widget.recipientId ?? '')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot messageDoc = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(messageDoc['content']),
                      subtitle: Text(messageDoc['timestamp'].toString()),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      FirebaseFirestore.instance.collection('messages').add({
        'senderId': FirebaseAuth.instance.currentUser?.uid,
        'recipientId': widget.recipientId,
        'content': message,
        'timestamp': DateTime.now(),
      });
      _messageController.clear();
    }
  }
}

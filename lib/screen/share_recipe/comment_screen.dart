import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CommentScreen extends StatefulWidget {
  final String userUid;
  final String recipeId;

  const CommentScreen({
    required this.userUid,
    required this.recipeId,
    Key? key,
  }) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();

  List<Comment> _comments = [];

  DocumentSnapshot? userData;
  String? _userImageUrl;

  final _userNameController = TextEditingController();
  bool _isDataFetched = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .where('userUid', isEqualTo: widget.userUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final comments = snapshot.data!.docs.map((doc) {
                  return Comment.fromMap(doc.data() as Map<String, dynamic>);
                }).toList();
                return ListView.separated(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final Comment comment = comments[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                        horizontal: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: CustomPaint(
                              painter: ChatBubblePaint(),
                              child: GestureDetector(
                                onLongPress: () {
                                  _showDeleteConfirmationDialog(comment);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: comment.imageUrl !=
                                                    null
                                                ? NetworkImage(comment.imageUrl)
                                                : AssetImage(
                                                    'assets/images/user_image.jpg',
                                                  ) as ImageProvider,
                                          ),
                                          Text(
                                            comment.username != null &&
                                                    comment.username.isNotEmpty
                                                ? comment.username
                                                : 'Name: Unknown',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: size.width *
                                            0.2 *
                                            3.15, // Adjust according to your chat box width
                                        child: RichText(
                                          text: TextSpan(
                                            text: comment.comment ?? '',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          maxLines: 13,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        comment.timestamp != null
                                            ? '${DateFormat('dd-MM-yyyy').format(comment.timestamp.toDate())}\n${DateFormat('HH:mm').format(comment.timestamp.toDate())}'
                                            : '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 20.0);
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
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _postComment,
                  child: Text('Post'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(commentId)
          .delete();
      // Update the UI after deleting the comment
      _fetchComments();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment deleted successfully'),
        ),
      );
    } catch (e) {
      print('Error deleting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete comment: $e'),
        ),
      );
    }
  }

  Future<void> _fetchComments() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('recipeId', isEqualTo: widget.recipeId)
          .get();
      setState(() {
        _comments = snapshot.docs
            .map((doc) => Comment.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  void _showDeleteConfirmationDialog(Comment comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Comment"),
          content: Text("Are you sure you want to delete this comment?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteComment(comment.id);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _postComment() async {
    final String comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final DocumentSnapshot userDataSnapshot = await FirebaseFirestore
              .instance
              .collection('profiles')
              .doc(user.uid)
              .get();
          if (userDataSnapshot.exists) {
            final userData = userDataSnapshot.data() as Map<String, dynamic>;
            final String username = userData['name'] ?? 'Unknown';
            final String imageUrl = userData['imageUrl'] ?? '';
            final String recipeId = widget.recipeId;
            final String id =
                FirebaseFirestore.instance.collection('comments').doc().id;
            await FirebaseFirestore.instance
                .collection('comments')
                .doc(id)
                .set({
              'id': id,
              'userUid': user.uid,
              'username': username,
              'imageUrl': imageUrl,
              'comment': comment,
              'timestamp': Timestamp.now(),
              'recipeId': recipeId,
            });
            _commentController.clear();
            _fetchComments();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Comment posted successfully'),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Failed to fetch user data. Please try again later.'),
              ),
            );
          }
        } catch (e) {
          print('Error posting comment: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to post comment. Please try again later.'),
            ),
          );
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please sign in to post a comment'),
          ),
        );
      }
    }
  }
}

class Comment {
  String id;
  String userUid;
  String username;
  String imageUrl;
  String comment;
  Timestamp timestamp;
  String recipeId;

  Comment({
    required this.id,
    required this.userUid,
    required this.username,
    required this.imageUrl,
    required this.comment,
    required this.timestamp,
    required this.recipeId,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    final String id = map['id'] ?? '';
    final String recipeId = map['recipeId'] ?? '';
    return Comment(
      id: id,
      userUid: map['userUid'] ?? '',
      username: map['username'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      comment: map['comment'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
      recipeId: recipeId,
    );
  }
}

class ChatBubblePaint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromARGB(255, 222, 209, 209)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.1)
      ..lineTo(size.width * 0.85, size.height * 0.1)
      ..lineTo(size.width * 0.85, size.height * 0.95)
      ..lineTo(size.width * 0.2, size.height * 0.95)
      ..lineTo(size.width * 0.2, size.height * 1.05)
      ..lineTo(size.width * 0.1, size.height * 0.95)
      ..lineTo(0, size.height * 0.95);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

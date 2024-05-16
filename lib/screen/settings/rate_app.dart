import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateAppScreen extends StatelessWidget {
  final CollectionReference ratingsCollection =
      FirebaseFirestore.instance.collection('ratings');

  double userRating = 3.0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 242, 240, 240),
        elevation: 0,
        title: Text(
          'Rate App',
          style: TextStyle(
              color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RatingBar.builder(
              initialRating: 3,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 50,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.red,
              ),
              onRatingUpdate: (rating) {
                print("User's rating: $rating");
                userRating = rating;
              },
            ),
            SizedBox(height: 40),
            Center(
              child: Text(
                'Enjoying Our App?',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: Text(
                'Your feedback helps us improve! Please take a moment to rate our app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 30),
            MaterialButton(
              onPressed: () async {
                print('Dialog will be shown');
                // Show a dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Thank you for your rating!'),
                      content: Text(
                        'We value your feedback. Feel free to share any comments or suggestions. We\'re here to listen. Thank you for supporting us!',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              color: Colors.red,
              shape: StadiumBorder(),
              height: 50,
              child: Text(
                'Rate Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

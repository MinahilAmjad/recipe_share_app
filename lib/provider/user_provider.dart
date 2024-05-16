import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider extends ChangeNotifier {
  late String _userUid;
  late String _name = '';
  late String _imageUrl = '';
  late String _website = '';

  String get userUid => _userUid;
  String get name => _name;
  String get imageUrl => _imageUrl;
  String get website => _website;

  void setUserUid(String userUid) {
    _userUid = userUid;
  }

  // fetch user profile data from Firestore
  Future<void> fetchUserData() async {
    try {
      final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(_userUid)
          .get();

      if (profileSnapshot.exists) {
        final profileData = profileSnapshot.data() as Map<String, dynamic>;

        _name = profileData['name'] ?? '';
        _imageUrl = profileData['imageUrl'] ?? '';
        _website = profileData['website'] ?? '';

        notifyListeners();
      } else {
        print('Profile data not found for user UID: $_userUid');
        _name = '';
        _imageUrl = '';
        _website = '';
        notifyListeners();
      }
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  //  update user  data
  Future<void> updateUserData({
    required String name,
    required String imageUrl,
    required String website,
  }) async {
    try {
      // udpdate
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(_userUid)
          .set({
        'name': name,
        'imageUrl': imageUrl,
        'website': website,
      });

      // Update local data
      _name = name;
      _imageUrl = imageUrl;
      _website = website;

      notifyListeners();
    } catch (error) {
      print('Error updating profile data: $error');
    }
  }
}

class UserModel {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoURL;

  UserModel({
    this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });
// in map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid ?? 'uid',
      'email': email ?? '',
      'displayName': displayName ?? '',
      'photoURL': photoURL,
    };
  }

//factory method
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
    );
  }
}

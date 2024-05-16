class ProfileModel {
  String? userName;
  String? website;
  String? bio;
  String? birthday;
  String? gender;
  String? photoURL;

  ProfileModel({
    this.userName,
    this.website,
    this.bio,
    this.birthday,
    this.gender,
    this.photoURL,
  });

  set _userImageURL(_userImageURL) {}

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'website': website,
      'bio': bio,
      'birthday': birthday,
      'gender': gender,
      'photoURL': photoURL,
    };
  }

  static ProfileModel fromJson(Map<String, dynamic> data) {
    return ProfileModel(
      userName: data['userName'],
      website: data['website'],
      bio: data['bio'],
      birthday: data['birthday'],
      gender: data['gender'],
      photoURL: data['photoURL'],
    );
  }
}

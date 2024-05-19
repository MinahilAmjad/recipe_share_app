import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final String userUid;

  const EditProfileScreen({required this.userUid});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  String _selectedGender = 'Male';
  DateTime? _selectedDate;
  File? _pickedImage;
  String imageUrl = '';

  late String userUid = '';

  late User _currentUser;
  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    userUid = _currentUser.uid;
    if (widget.userUid.isNotEmpty) {
      _fetchProfileData();
    } else {
      print('User UID is empty');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  
  Future<void> _saveProfile() async {
    try {
      // Check if previous profile exists
      final previousProfileDoc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(_currentUser.uid)
          .get();

      // Delete previous profile if it exists
      if (previousProfileDoc.exists) {
        await previousProfileDoc.reference.delete();
      }

      // Upload image and get download URL if image is picked
      String? imageUrl;
      if (_pickedImage != null) {
        imageUrl = await uploadImageAndGetDownloadURL(_pickedImage!,
            _currentUser.uid); // Pass user UID to the upload function
        if (imageUrl == null) {
          Fluttertoast.showToast(msg: 'Failed to upload image');
          return;
        }
      }
      //save data
      final profileData = {
        'name': _nameController.text,
        'bio': _bioController.text,
        'website': _websiteController.text,
        'birthday': _selectedDate,
        'gender': _selectedGender,
        'imageUrl': imageUrl,
      };

      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(_currentUser.uid)
          .set(profileData);

      // Update UserProvider data

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profile saved successfully')));
    } catch (error) {
      print('Failed to save profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $error')));
    }
  }

  Future<void> _fetchProfileData() async {
    try {
      final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(_currentUser.uid)
          .get();

      if (profileSnapshot.exists) {
        final Map<String, dynamic> profileData =
            profileSnapshot.data() as Map<String, dynamic>;

        _nameController.text = profileData['name'] ?? '';
        _bioController.text = profileData['bio'] ?? '';
        _websiteController.text = profileData['website'] ?? '';

        setState(() {
          _selectedDate = (profileData['birthday'] ?? DateTime.now()).toDate();
        });

        setState(() {
          _selectedGender = profileData['gender'] ?? 'Male';
        });

        if (userUid == _currentUser.uid && profileData['imageUrl'] != null) {
          await _downloadAndSetImage(profileData['imageUrl']);
        }
      } else {
        print('Profile data not found for user UID: $userUid');
      }
    } catch (error) {
      print('Error fetching profile data: $error');
    }
  }

  Future<void> _downloadAndSetImage(String imageUrl) async {
    try {
      Uri uri = Uri.parse(imageUrl);
      if (uri.scheme == 'http' || uri.scheme == 'https') {
        final http.Response response = await http.get(uri);
        final tempDir = await getTemporaryDirectory();
        final File tempImage = File('${tempDir.path}/temp_image.jpg');
        await tempImage.writeAsBytes(response.bodyBytes);
        setState(() {
          _pickedImage = tempImage;
        });
      } else {
        print('Invalid URL scheme: ${uri.scheme}');
      }
    } catch (error) {
      print('Error downloading image: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                backgroundColor: Color.fromARGB(255, 232, 228, 228),

        title: Text(' Edit Profile'),
        actions: [
          IconButton(
            onPressed: _saveProfile,
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 100,
                child: ClipOval(
                  child: InkWell(
                    onTap: () => showModalBottomSheetSuggestions(context),
                    child: Container(
                      child: _pickedImage != null
                          ? Image.file(
                              _pickedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Icon(Icons.person, size: 80),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'bio',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 4,
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(
                    labelText: 'Website',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              SizedBox(height: 30.0),
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedDate != null)
                      Text(
                        'Birthday: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                      ),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        'Select date',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
                items: ['Male', 'Female', 'Other']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showModalBottomSheetSuggestions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Pick From Camera'),
                onTap: () => _pickFromCamera(),
              ),
              ListTile(
                leading: const Icon(Icons.image_search_outlined),
                title: const Text('Pick From Gallery'),
                onTap: () => _pickFromGallery(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    Navigator.pop(context);
    try {
      final XFile? selectedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (selectedImage != null) {
        setState(() {
          _pickedImage = File(selectedImage.path);
        });
        Fluttertoast.showToast(msg: 'Image Selected');
      } else {
        Fluttertoast.showToast(msg: 'Image Not Selected');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> _pickFromGallery() async {
    Navigator.pop(context);
    try {
      final XFile? selectedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (selectedImage != null) {
        setState(() {
          _pickedImage = File(selectedImage.path);
        });
        Fluttertoast.showToast(msg: 'Image Selected');
      } else {
        Fluttertoast.showToast(msg: 'Image Not Selected');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<String?> uploadImageAndGetDownloadURL(
      File imageFile, String userUid) async {
    try {
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userUid.jpg'); // Store image with user UID as filename
      UploadTask uploadTask = storageRef.putFile(imageFile);

      await uploadTask;

      String downloadURL = await storageRef.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}

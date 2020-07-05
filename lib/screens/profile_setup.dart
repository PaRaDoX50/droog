import 'dart:io';

import 'package:droog/models/enums.dart';
import 'package:droog/screens/home.dart';
import 'package:droog/screens/new_post.dart';
import 'package:droog/services/database_methods.dart';
import 'file:///P:/androidProjects/Droog/droog/lib/utils/image_picker.dart';
import 'package:droog/services/sharedprefs_methods.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetup extends StatefulWidget {
  static final String route= "/profile_setup";
  @override
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  PickImage _imagePicker = PickImage();
  bool showLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController userNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  DatabaseMethods _databaseMethods = DatabaseMethods();
  SharedPrefsMethods _sharedPrefsMethods = SharedPrefsMethods();
  File _takenImage;

  void _showSnackBar(String content) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(content),
    ));
  }

  Widget _buildForm() {
    final firstNameField = TextFormField(
      controller: firstNameController,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field can't be empty";
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 8, right: 0, top: 0, bottom: 0),
        hintText: "First Name",
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );

    final lastNameField = TextFormField(
      controller: lastNameController,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field can't be empty";
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 8, right: 0, top: 0, bottom: 0),
        hintText: "Last Name",
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );

    final userNameField = TextFormField(
      controller: userNameController,
      validator: (val) {
        if (val.isNotEmpty) {
          return null;
        }
        return "This field can't be empty";
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 8, right: 0, top: 0, bottom: 0),
        hintText: "User-Name",
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );

    final descriptionField = TextFormField(
      controller: descriptionController,
      maxLines: 10,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.only(left: 8, right: 0, top: 16, bottom: 0),
        hintText: "Describe yourself",
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      maxLength: 180,
    );

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          firstNameField,
          SizedBox(
            height: 16,
          ),
          lastNameField,
          SizedBox(
            height: 16,
          ),
          userNameField,
          SizedBox(
            height: 16,
          ),
          descriptionField,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainWidget = SingleChildScrollView(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Profile Setup",
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _takenImage != null
                      ? ClipOval(
                          child: Image.file(
                            _takenImage,
                            width: 70,
                            height: 70,
                          ),
                        )
                      : Icon(
                          Icons.account_circle,
                          size: 80,
                        ),
                  RaisedButton(
                    child:
                        Text("Add", style: Theme.of(context).textTheme.button),
                    color: Theme.of(context).buttonColor,
                    onPressed: () async {
                      File image =
                          await _imagePicker.takePicture(imageSource: ImageSource.camera);
                      if (image != null) {
                        File croppedImage = await _imagePicker.cropImage(
                            image: image,
                            pictureFor: PictureFor.profilePicture,ratioY: 1,ratioX: 1);
                        if (croppedImage != null) {
                          setState(() {
                            _takenImage = croppedImage;
                          });
                          await _sharedPrefsMethods
                              .saveProfilePicturePath(croppedImage.path);
                        } else {
                          _showSnackBar("Something went wrong.");
                        }
                      } else {
                        _showSnackBar("Something went wrong.");
                      }
                    },
                  )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              _buildForm(),
              SizedBox(
                height: 16,
              ),
              RaisedButton(
                child:
                    Text("Submit", style: Theme.of(context).textTheme.button),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    if (await _databaseMethods
                        .userNameAvailable(userName:userNameController.text)) {
                      if (_takenImage != null) {
                        setState(() {
                          showLoading = true;
                        });

                        try {
                          String downloadUrl = await _databaseMethods
                              .uploadPicture(file: _takenImage,address: "profilePictures");
                          if (downloadUrl != null) {
                            await _databaseMethods.completeUserProfile(
                                userName: userNameController.text,
                                description: descriptionController.text,
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                profilePictureUrl: downloadUrl);
                          }

                          await _sharedPrefsMethods.completeUserPrefs(
                              firstName: firstNameController.text,
                              lastName: lastNameController.text,
                              userName: userNameController.text,
                              loggedInStatus: LoggedInStatus.loggedIn);
                          Navigator.pushReplacementNamed(
                              context, Home.route);
                          setState(() {
                            showLoading = false;
                          });
                        } catch (e) {
                          setState(() {
                            showLoading = false;
                          });
                          _showSnackBar("Something went wrong");
                          print(e.toString());
                        }
                      } else {
                        _showSnackBar(
                            "You need to select your profile picture");
                      }
                    } else {
                      _showSnackBar("User Name not available");
                    }
                  }
                },
                color: Theme.of(context).buttonColor,
              ),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          Color(0xff1948a0),
          Color(0xff2d63ad),
          Color(0xff4481bc)
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Stack(
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: mainWidget,
              ),
            ),
            showLoading == true
                ? Center(child: CircularProgressIndicator())
                : Container()
          ],
        ),
      ),
    );
  }
}

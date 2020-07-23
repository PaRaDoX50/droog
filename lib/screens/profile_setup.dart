import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/screens/home.dart';
import 'package:droog/screens/skills_setup.dart';
import 'package:droog/services/database_methods.dart';
import 'file:///P:/androidProjects/Droog/droog/lib/utils/image_picker.dart';
import 'package:droog/services/sharedprefs_methods.dart';
import 'package:droog/utils/theme_data.dart';
import 'package:droog/widgets/profile_picture_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfileSetup extends StatefulWidget {
  static final String route = "/profile_setup";

  @override
  _ProfileSetupState createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  PickImage _imagePicker = PickImage();
  bool showLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  RoutedProfileSetupFor profileSetupFor;
  TextEditingController userNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  DatabaseMethods _databaseMethods = DatabaseMethods();
  SharedPrefsMethods _sharedPrefsMethods = SharedPrefsMethods();
  File _takenImage;

  void _showSnackBar(String content) {
    _scaffoldKey.currentState.showSnackBar((MyThemeData.getSnackBar(text: content)));
  }

  showImageSourceOptions() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Color(0xff1948a0),
                  Color(0xff2d63ad),
                  Color(0xff4481bc)
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.camera,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        addImage(imageSource: ImageSource.camera);
                      },
                    ),
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.image,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        addImage(imageSource: ImageSource.gallery);
                      },
                    )
                  ],
                ),
              ),
              elevation: 5,
            ));
  }

  addImage({ImageSource imageSource}) async {
    File image = await _imagePicker.takePicture(imageSource: imageSource);
    if (image != null) {
      File croppedImage = await _imagePicker.cropImage(
          image: image,
          pictureFor: PictureFor.profilePicture,
          ratioY: 1,
          ratioX: 1);
      if (croppedImage != null) {
        print("Reached cropped");

        setState(() {
          imageCache.clear();
          imageCache.clearLiveImages();
          _takenImage = croppedImage;
        });
        print("Reached cropped2");
//        await _sharedPrefsMethods
//            .saveProfilePicturePath(croppedImage.path);
        print("Reached cropped3");
      } else {
        _showSnackBar("Something went wrong.");
      }
    } else {
      _showSnackBar("Something went wrong.");
    }
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
      maxLines: 5,
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

  loadInitialData() {
    firstNameController = TextEditingController(text: Constants.firstName);
    lastNameController = TextEditingController(text: Constants.lastName);
    userNameController = TextEditingController(text: Constants.userName);
    descriptionController = TextEditingController(text: Constants.descriptiom);
  }

  @override
  Widget build(BuildContext context) {
    profileSetupFor =
        ModalRoute.of(context).settings.arguments as RoutedProfileSetupFor;
    if (profileSetupFor == RoutedProfileSetupFor.edit) {
      loadInitialData();
    }
    Widget mainWidget = SingleChildScrollView(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FittedBox(
                child: Text(
                  "Profile Setup",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Stack(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: _takenImage != null
                        ? Center(
                            child: ClipOval(
                              child: Image.file(
                                _takenImage,
                                width: 70,
                                height: 70,
                                key: ValueKey(_takenImage.lengthSync()),
                              ),
                            ),
                          )
                        : profileSetupFor == RoutedProfileSetupFor.edit
                            ? CircleAvatar(
                                radius: 35,
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: Constants.profilePictureUrl,
                                    placeholder: (x, y) {
                                      return  ProfilePictureLoading();
                                    },
                                  ),
                                ),
                              )
                            : Center(
                                child: CircleAvatar(
                                child: ClipOval(
                                    child: FadeInImage(image:AssetImage(
                                        "assets/images/camera.png"),
                                      placeholder: MemoryImage(kTransparentImage),),),
                                radius: 35,
                                backgroundColor: Colors.transparent,
                              ),),
                  ),
                  Positioned(
                    right: 20,
                    top: 20,

                    child: SizedBox(
                      height: 30,
                      child: RaisedButton(
                        child: Text("Add",
                            style: Theme.of(context).textTheme.button),
                        color: Theme.of(context).buttonColor,
                        onPressed: showImageSourceOptions,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 8,
              ),
              _buildForm(),
              SizedBox(
                height: 8,
              ),
              RaisedButton(
                child:
                    Text("Submit", style: Theme.of(context).textTheme.button),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    if (await _databaseMethods.userNameAvailable(
                            userName: userNameController.text) ||
                        userNameController.text == Constants.userName) {
                      if (_takenImage != null ||
                          profileSetupFor == RoutedProfileSetupFor.edit) {
                        setState(() {
                          showLoading = true;
                        });

                        try {
                          if (_takenImage != null) {
                            String downloadUrl =
                                await _databaseMethods.uploadPicture(
                                    file: _takenImage,
                                    address: "profilePictures");

                            await _databaseMethods.completeUserProfile(
                                userName: userNameController.text,
                                description: descriptionController.text,
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                profilePictureUrl: downloadUrl);

                            await _sharedPrefsMethods.completeUserPrefs(
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                userName: userNameController.text,
                                profilePictureUrl: downloadUrl,
                                description: descriptionController.text,
                                loggedInStatus: LoggedInStatus.loggedIn);
                          } else {
                            await _databaseMethods.completeUserProfile(
                                userName: userNameController.text,
                                description: descriptionController.text,
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                profilePictureUrl: Constants.profilePictureUrl);

                            await _sharedPrefsMethods.completeUserPrefs(
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                userName: userNameController.text,
                                profilePictureUrl: Constants.profilePictureUrl,
                                description: descriptionController.text,
                                loggedInStatus: LoggedInStatus.loggedIn);
                          }

                          if (profileSetupFor == RoutedProfileSetupFor.setup) {
                            print("reachedIf");
                            Navigator.pushReplacementNamed(
                                context, SkillsSetup.route);
                          } else if (profileSetupFor ==
                              RoutedProfileSetupFor.edit) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, Home.route, (r) => false);
                          }
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
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      key: _scaffoldKey,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(stops: [
          0,
          .5,
          1,
        ], colors: [
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

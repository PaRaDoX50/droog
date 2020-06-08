import 'dart:io';

import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/services/database_methods.dart';
import 'package:droog/services/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewPost extends StatefulWidget {
  static final String route = "/new_post";

  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  File _attachedImage;
  TextEditingController descriptionController = TextEditingController();
  DatabaseMethods _databaseMethods = DatabaseMethods();
  PickImage _pickImage = PickImage();

  Future _getProfilePicture() async {
    try {
      final profilePicturePath = await Constants.getProfilePicturePath();
      return File(profilePicturePath);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget _buildTextField() {
    final maxLines = 11;

    return TextField(
      controller: descriptionController,
      maxLines: maxLines,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        hintText: "Describe your doubt",
      ),
    );
  }

  Widget _buildShareButton() {
    return Container(
      width: double.infinity,
      child: RaisedButton(
        onPressed: () async {
          try {
            if (_attachedImage != null) {
              print("upload");
              String imageUrl = await _databaseMethods.uploadPictureForPost(
                  file: _attachedImage);
              print("upload complete" + imageUrl);

              if (imageUrl != null) {
                await _databaseMethods.makeAPost(
                    description: descriptionController.text,
                    imageUrl: imageUrl);
                print("post complete");
              }
            } else {
              await _databaseMethods.makeAPost(
                  description: descriptionController.text);
              print("post complete without picture");
            }
          } catch (e) {
            print(e.toString());
          }
        },
        child: Text(
          "Share",
          style: Theme.of(context).textTheme.button,
        ),
      ),
    );
  }

  Widget _buildUserTile() {
    return ListTile(
      leading: ClipOval(
        child: FutureBuilder(
          future: _getProfilePicture(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.file(
                snapshot.data,
              );
            }
            return CircleAvatar(
                child: Icon(
              Icons.account_circle,
            ));
          },
        ),
      ),
      title: Text(Constants.userName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildUserTile(),
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildTextField(),
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: InkWell(
                          onTap: () async {
                            File image = await _pickImage
                                .takePicture(ImageSource.camera);
                            File croppedImage;
                            if (image != null) {
                              croppedImage = await _pickImage.cropImage(
                                  image: image,
                                  pictureFor: PictureFor.postPicture);
                            }
                            if (croppedImage != null) {
                              setState(() {
                                _attachedImage = croppedImage;
                              });
                            }
                          },
                          child: Icon(Icons.camera_alt),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: InkWell(
                          onTap: () async {
                            File image = await _pickImage
                                .takePicture(ImageSource.gallery);
                            File croppedImage;
                            if (image != null) {
                              croppedImage = await _pickImage.cropImage(
                                  image: image,
                                  pictureFor: PictureFor.postPicture);
                            }
                            if (croppedImage != null) {
                              setState(() {
                                _attachedImage = croppedImage;
                              });
                            }
                          },
                          child: Icon(Icons.attachment),
                        ),
                      ),
                    ],
                  ),
                  _attachedImage != null
                      ? Image.file(
                          _attachedImage,
                          height: 80,
                          width: 80,
                        )
                      : Container(),
                  _buildShareButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

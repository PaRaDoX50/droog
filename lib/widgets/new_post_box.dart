import 'dart:io';

import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:droog/models/post.dart';
import 'package:droog/services/database_methods.dart';
import 'file:///P:/androidProjects/Droog/droog/lib/utils/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewPostBox extends StatefulWidget {
  static final String route = "/new_post";
  PostIs postIs;
  String postId;

  NewPostBox({this.postIs, this.postId});

  @override
  _NewPostBoxState createState() => _NewPostBoxState();
}

class _NewPostBoxState extends State<NewPostBox> {
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
    final maxLines = widget.postIs == PostIs.normalPost ? 11 : 2;

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
              String imageUrl;
              if (widget.postIs == PostIs.normalPost) {
                imageUrl = await _databaseMethods.uploadPicture(
                    file: _attachedImage,address: "postPictures");
              } else if (widget.postIs == PostIs.response) {
                imageUrl = await _databaseMethods.uploadPicture(
                    file: _attachedImage,address: "responsePictures");
              }
              print("upload complete" + imageUrl);

              if (imageUrl != null) {
                if (widget.postIs == PostIs.normalPost) {
                  await _databaseMethods.makeAPost(
                      description: descriptionController.text,
                      imageUrl: imageUrl);
                  print("post complete");
                } else if (widget.postIs == PostIs.response) {
                  await _databaseMethods.makeAResponse(
                      postId: widget.postId,
                      imageUrl: imageUrl,
                      description: descriptionController.text);
                }
              }
            } else {
              if (widget.postIs == PostIs.normalPost) {
                await _databaseMethods.makeAPost(
                    description: descriptionController.text);
              } else if (widget.postIs == PostIs.response) {
                await _databaseMethods.makeAResponse(
                    postId: widget.postId,
                    description: descriptionController.text);
              }
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
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 8/2),
        child: Center(
          child: Card(
            elevation: 10,
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
                                .takePicture(imageSource: ImageSource.camera);
                            File croppedImage;
                            if (image != null) {
                              croppedImage = await _pickImage.cropImage(
                                  image: image,
                                  pictureFor: PictureFor.postPicture,
                                  ratioX: 4,
                                  ratioY: 3);
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
                                .takePicture(imageSource: ImageSource.gallery);
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
      );
  }
}

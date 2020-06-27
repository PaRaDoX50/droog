import 'dart:io';

import 'package:droog/data/constants.dart';
import 'package:droog/models/enums.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PickImage{
  Future<File> takePicture({ImageSource imageSource}) async {
    try {
      final _imagePicker = ImagePicker();
      final imagePickerFile = await _imagePicker.getImage(
          source: imageSource,

      );
      File imageFile = File(imagePickerFile.path);
      if (imageFile == null) {
        return null;
      }




      return imageFile;
    }  catch (e) {
      print(e.toString());
    }

//    var _imageToStore = Picture(picName: savedImage);
//    _storeImage() {
//      Provider.of<Pictures>(context, listen: false).storeImage(_imageToStore);
//    }

//    _storeImage();
  }

  Future<File> cropImage({File image,PictureFor pictureFor,double ratioX,double ratioY}) async {
    File croppedImageFile =await ImageCropper.cropImage(sourcePath: image.path,aspectRatio: CropAspectRatio(ratioX: ratioX,ratioY: ratioY),compressQuality: 15);
    if(croppedImageFile == null){
      return null;
    }
    print(croppedImageFile.path + " file name");


//    final fileName = basename(croppedImageFile.path);
    File savedImage;
    if(pictureFor == PictureFor.profilePicture) {
      String profilePicturePath =await Constants.getProfilePicturePath();
      savedImage =
      await croppedImageFile.copy(profilePicturePath);
      return savedImage;
    }
    else  {
      return croppedImageFile;
    }


  }
}
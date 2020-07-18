import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class WebblenImagePicker {
  final BuildContext context;
  final double ratioX;
  final double ratioY;

  WebblenImagePicker({
    this.context,
    this.ratioX,
    this.ratioY,
  });

  final ImagePicker imagePicker = ImagePicker();

  Future<File> retrieveImageFromLibrary() async {
    imageCache.clear();
    File croppedImageFile;
    final pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    File img = File(pickedFile.path);
    if (img != null) {
      croppedImageFile = await cropImage(img);
    }
    return croppedImageFile;
  }

  Future<File> retrieveImageFromCamera() async {
    imageCache.clear();
    File croppedImageFile;
    final pickedFile = await imagePicker.getImage(source: ImageSource.camera);
    File img = File(pickedFile.path);
    if (img != null) {
      croppedImageFile = await cropImage(img);
    }
    return croppedImageFile;
  }

  Future<File> cropImage(File img) async {
    File croppedImageFile;
    croppedImageFile = await ImageCropper.cropImage(
      sourcePath: img.path,
      aspectRatio: CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
      compressFormat: ImageCompressFormat.png,
      compressQuality: 50,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.white,
      ),
    );
    return croppedImageFile;
  }
}

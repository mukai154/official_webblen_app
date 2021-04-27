import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class WebblenImagePicker {
  final BuildContext? context;
  final double? ratioX;
  final double? ratioY;

  WebblenImagePicker({
    this.context,
    this.ratioX,
    this.ratioY,
  });

  final ImagePicker _imagePicker = ImagePicker();

  Future<File?> retrieveImageFromLibrary({double? ratioX, double? ratioY}) async {
    imageCache!.clear();
    File? croppedImageFile;
    final pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File img = File(pickedFile.path);
      if (img != null) {
        croppedImageFile = await cropAndCompressImage(img: img, ratioX: ratioX!, ratioY: ratioY!);
      }
    }
    return croppedImageFile;
  }

  Future<File?> retrieveImageFromCamera({double? ratioX, double? ratioY}) async {
    imageCache!.clear();
    File? croppedImageFile;
    final pickedFile = await _imagePicker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File img = File(pickedFile.path);
      if (img != null) {
        croppedImageFile = await cropAndCompressImage(
          img: img,
          ratioX: ratioX!,
          ratioY: ratioY!,
        );
      }
    }
    return croppedImageFile;
  }

  Future<File?> cropAndCompressImage({required File img, required double ratioX, required double ratioY}) async {
    File? croppedImageFile;
    croppedImageFile = await ImageCropper.cropImage(
      sourcePath: img.path,
      aspectRatio: CropAspectRatio(
        ratioX: ratioX,
        ratioY: ratioY,
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

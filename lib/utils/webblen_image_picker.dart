import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class WebblenImagePicker {
  final BuildContext context;
  final double ratioX;
  final double ratioY;

  WebblenImagePicker({this.context, this.ratioX, this.ratioY});

  Future<File> retrieveImageFromLibrary() async {
    imageCache.clear();
    var dir = await path_provider.getTemporaryDirectory();
    var targetPath = dir.absolute.path + "/temp.png";
    File croppedImageFile;
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      croppedImageFile = await cropImage(img);
      if (croppedImageFile != null) {
        croppedImageFile = await FlutterImageCompress.compressAndGetFile(
          croppedImageFile.absolute.path,
          targetPath,
          quality: 45,
        );
      }
    }
    return croppedImageFile;
  }

  Future<File> retrieveImageFromCamera() async {
    imageCache.clear();
    var dir = await path_provider.getTemporaryDirectory();
    var targetPath = dir.absolute.path + "/temp.png";
    File croppedImageFile;
    File img = await ImagePicker.pickImage(source: ImageSource.camera);
    if (img != null) {
      croppedImageFile = await cropImage(img);
      if (croppedImageFile != null) {
        croppedImageFile = await FlutterImageCompress.compressAndGetFile(
          croppedImageFile.absolute.path,
          targetPath,
          quality: 25,
        );
      }
    }
    return croppedImageFile;
  }

  Future<File> cropImage(File img) async {
    File croppedImageFile;
    croppedImageFile = await ImageCropper.cropImage(
      sourcePath: img.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      androidUiSettings: AndroidUiSettings(toolbarTitle: 'Crop Image', toolbarColor: Colors.white),
    );
    return croppedImageFile;
  }
}

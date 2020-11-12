import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FileUploader {
  final Reference storageReference = FirebaseStorage.instance.ref();

  Future<String> uploadProfilePic(File userImage, String fileName) async {
    Reference storageReference = FirebaseStorage.instance.ref();
    Reference ref = storageReference.child("profile_pics").child(fileName);
    UploadTask uploadTask = ref.putFile(userImage);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }
}

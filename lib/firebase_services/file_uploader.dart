import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FileUploader {
  final StorageReference storageReference = FirebaseStorage.instance.ref();

  Future<String> upload(
      File file, String fileName, String collectionName) async {
    StorageReference ref =
        storageReference.child(collectionName).child(fileName);
    StorageUploadTask uploadTask = ref.putFile(file);
    String downloadUrl =
        await (await uploadTask.onComplete).ref.getDownloadURL() as String;
    return downloadUrl;
  }
}

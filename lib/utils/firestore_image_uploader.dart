import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirestoreImageUploader {
  final Reference storageReference = FirebaseStorage.instance.ref();

  Future<String> uploadImage({File img, String storageBucket, String folderName, String fileName}) async {
    Reference storageReference = FirebaseStorage.instance.ref();
    Reference ref = storageReference.child(storageBucket).child(folderName).child(fileName);
    UploadTask uploadTask = ref.putFile(img);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }
}

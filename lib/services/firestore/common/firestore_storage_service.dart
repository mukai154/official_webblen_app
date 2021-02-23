import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirestoreStorageService {
  final Reference storageReference = FirebaseStorage.instance.ref();

  Future<String> uploadImage({@required File img, @required String storageBucket, @required String folderName, @required String fileName}) async {
    Reference storageReference = FirebaseStorage.instance.ref();
    Reference ref = storageReference.child(storageBucket).child(folderName).child(fileName);
    UploadTask uploadTask = ref.putFile(img);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }
}

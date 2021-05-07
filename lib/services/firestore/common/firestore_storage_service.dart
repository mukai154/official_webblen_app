import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirestoreStorageService {
  final Reference storageReference = FirebaseStorage.instance.ref();

  Future<String?> uploadImage({required File img, required String storageBucket, required String folderName, required String fileName}) async {
    String? downloadURL;
    Reference ref = storageReference.child(storageBucket).child(folderName).child(fileName);

    //meta data for system caching
    SettableMetadata metadata = SettableMetadata(
      contentType: "image/jpeg",
      cacheControl: 'public, max-age=3600, s-maxage=3600',
    );

    UploadTask uploadTask = ref.putFile(img, metadata);
    await uploadTask;

    //attempts to get url for resized image file
    int attempts = 0;

    while (attempts < 10 && downloadURL == null) {
      await Future.delayed(Duration(milliseconds: 500));
      downloadURL = await attemptToGetDownloadURL(storageBucket: storageBucket, folderName: folderName, fileName: fileName);
      attempts += 1;
    }

    return downloadURL;
  }

  Future<String?> attemptToGetDownloadURL({required String storageBucket, required String folderName, required String fileName}) async {
    String? downloadURL;

    await storageReference.child(storageBucket).child(folderName).child(fileName + "_500x500").getDownloadURL().then((result) {
      downloadURL = result.toString();
    }).catchError((e) {
      print(e);
    });

    return downloadURL;
  }

  Future<bool> deleteImage({required String storageBucket, required String folderName, required String fileName}) async {
    bool deletedImage = true;
    await storageReference.child(storageBucket).child(folderName).child(fileName + "_500x500").delete().catchError((e) {
      print(e);
      deletedImage = false;
    });
    return deletedImage;
  }
}

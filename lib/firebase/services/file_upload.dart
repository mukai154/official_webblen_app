import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FileUploader {
  final StorageReference storageReference = FirebaseStorage.instance.ref();

  Future<String> uploadProfilePic(File userImage, String fileName) async {
    StorageReference storageReference = FirebaseStorage.instance.ref();
    StorageReference ref = storageReference.child("profile_pics").child(fileName);
    StorageUploadTask uploadTask = ref.putFile(userImage);
    String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL() as String;
    return downloadUrl;
  }

  Future<String> uploadStreamVideo(File streamVideoFile, String uid, String fileName) async {
    String downloadUrl;
    StorageReference storageReference = FirebaseStorage.instance.ref();
    StorageReference ref = storageReference.child("stream_video").child(uid).child(fileName);
    print(streamVideoFile);
    StorageUploadTask uploadTask = ref.putFile(
      streamVideoFile,
      StorageMetadata(
        contentType: 'video/mp4',
      ),
    );
    uploadTask.events.forEach((event) {
      print(event.snapshot.bytesTransferred.toString() + "/" + event.snapshot.totalByteCount.toString());
    });
    await uploadTask.onComplete.catchError((e) => print(e));
    downloadUrl = await ref.getDownloadURL() as String;
    return downloadUrl;
  }

  Future<String> uploadStreamAudio(File streamAudioFile, String uid, String fileName) async {
    StorageReference storageReference = FirebaseStorage.instance.ref();
    StorageReference ref = storageReference.child("stream_audio").child(uid).child(fileName);
    StorageUploadTask uploadTask = ref.putFile(
      streamAudioFile,
      StorageMetadata(
        contentType: 'audio/wav',
        customMetadata: <String, String>{'file': 'audio'},
      ),
    );
    String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL() as String;
    return downloadUrl;
  }
}

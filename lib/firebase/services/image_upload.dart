//import 'dart:io';
//
//import 'package:firebase/firebase.dart' as fb;
//
//const String EventImgFile = "event";
//const String UserImgFile = "profile_pics";
//
//class ImageUploadService {
//  fb.UploadTask uploadTask;
//  fb.UploadTaskSnapshot uploadTaskSnapshot;
//  Future<String> uploadImageToFirebaseStorage(File file, String fileType, String fileKey) async {
//    String imgURL;
//    String imageFilePath = '$fileType/$fileKey.png';
//    uploadTask = fb.storage().refFromURL("gs://webblen-events.appspot.com").child(imageFilePath).put(file);
//    uploadTaskSnapshot = await uploadTask.future;
//    imgURL = await (await uploadTaskSnapshot.ref.getDownloadURL()).toString();
//    return imgURL;
//  }
//}

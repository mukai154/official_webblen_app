import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:webblen/models/local_ad.dart';

class AdDataService {

  Geoflutterfire geo = Geoflutterfire();
  final CollectionReference localAdsRef = Firestore.instance.collection("local_ads");
  final StorageReference storageReference = FirebaseStorage.instance.ref();

  Future<String> uploadAd(File adImage,  LocalAd ad, double lat, double lon) async {
    String error = '';
    GeoFirePoint adLoc = geo.point(latitude: lat, longitude: lon);
    final String adKey = "${Random().nextInt(999999999)}";
    String fileName = "$adKey.jpg";
    String downloadUrl = await setAdImage(adImage, fileName);
    ad.imageURL = downloadUrl;
    ad.adKey = adKey;
    ad.location = adLoc.data;
    await localAdsRef.document(adKey).setData(ad.toMap()).whenComplete(() {
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<bool> adsExist(double lat, double lon) async {
    GeoFirePoint center = geo.point(latitude: lat, longitude: lon);
    List<DocumentSnapshot> nearAds = await geo.collection(collectionRef: localAdsRef).within(center: center, radius: 20, field: 'location').first;
    if (nearAds.length != 0) return true;
    return false;
  }

  Future<String> setAdImage(File adImage, String fileName) async {
    StorageReference ref = storageReference.child("local_ads").child(fileName);
    StorageUploadTask uploadTask = ref.putFile(adImage);
    String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL() as String;
    return downloadUrl;
  }

  Future<String> deleteAd(String adKey) async {
    String error = "";
    await localAdsRef.document(adKey).delete().whenComplete((){
      storageReference.child("local_ads").child("$adKey.jpg").delete();
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

}
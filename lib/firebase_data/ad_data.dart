import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:webblen/models/local_ad.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:webblen/firebase_services/file_uploader.dart';

class AdDataService {

  Geoflutterfire geo = Geoflutterfire();
  final CollectionReference adsRef = Firestore.instance.collection("native_ads");
  final StorageReference storageReference = FirebaseStorage.instance.ref();

  Future<String> uploadAd(File adImage,  LocalAd ad, double lat, double lon) async {
    String error = '';
    GeoFirePoint adLoc = geo.point(latitude: lat, longitude: lon);
    final String adKey = "${Random().nextInt(999999999)}";
    String fileName = "$adKey.jpg";
    ad.imageURL= await FileUploader().upload(adImage, fileName, 'native_ads');
    ad.adKey = adKey;
    await adsRef.document(adKey).setData({'d': ad.toMap(), 'g': adLoc.hash, 'l': adLoc.geoPoint}).whenComplete(() {
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

  Future<List<LocalAd>> getNearbyAds(double lat, double lon) async {
    List<LocalAd> localAds = [];
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'getNearbyAds');
    final HttpsCallableResult result = await callable.call(<String, dynamic>{'lat': lat, 'lon': lon});
    if (result.data != null){
      List adQuery =  List.from(result.data);
      adQuery.forEach((resultMap){
        Map<String, dynamic> adMap =  Map<String, dynamic>.from(resultMap);
        LocalAd ad = LocalAd.fromMap(adMap);
        localAds.add(ad);
      });
    }
    return localAds;
  }

  Future<String> deleteAd(String adKey) async {
    String error = "";
    await adsRef.document(adKey).delete().whenComplete((){
      storageReference.child("native_ads").child("$adKey.jpg").delete();
    }).catchError((e) {
      error = e.toString();
    });
    return error;
  }

}
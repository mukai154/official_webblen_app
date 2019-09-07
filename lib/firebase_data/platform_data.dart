import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class PlatformDataService {

  Future<bool> isUpdateAvailable() async {
    bool updateAvailable = false;
    String currentVersion = "7.1.0";
    DocumentSnapshot documentSnapshot = await Firestore.instance.collection("app_release_info").document("general").get();
    String releasedVersion = documentSnapshot.data["versionNumber"];
    bool versionIsRequired = documentSnapshot.data["versionIsRequired"];
    if (currentVersion != releasedVersion && versionIsRequired){
      updateAvailable = true;
    }
    return updateAvailable;
  }

  Future<String> getAreaGeoshash(double lat, double lon) async {
    String areaGeohash = "";
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: lat, longitude: lon);
    CollectionReference locRef = Firestore.instance.collection("available_locations");
    List<DocumentSnapshot> nearLocations = await geo.collection(collectionRef: locRef).within(center: center, radius: 20, field: 'location').first;
    if (nearLocations.length != 0) areaGeohash = nearLocations.first.data['location']['geohash'];
    return areaGeohash;
  }

  Future<String> getAreaName(double lat, double lon) async {
    String areaName = "";
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: lat, longitude: lon);
    CollectionReference locRef = Firestore.instance.collection("available_locations");
    List<DocumentSnapshot> nearLocations = await geo.collection(collectionRef: locRef).within(center: center, radius: 20, field: 'location').first;
    if (nearLocations.length != 0) areaName = nearLocations.first.documentID;
    return areaName;
  }

}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets_home_tiles/community_activity_tile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class StreamTop10NearbyUsers extends StatelessWidget {

  final WebblenUser currentUser;
  final double lat;
  final double lon;

  StreamTop10NearbyUsers({this.currentUser, this.lat, this.lon});

  @override
  Widget build(BuildContext context) {

    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: lat, longitude: lon);
    CollectionReference userRef = Firestore.instance.collection("users");

    return StreamBuilder(
      stream: geo.collection(collectionRef: userRef)
          .within(center: center, radius: 20, field: 'location'),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> docSnapshots) {
        List<WebblenUser> nearbyUsers = [];
        if (!docSnapshots.hasData) {
          return Container(
              height: 100,
              child: Center(
                child: CustomLinearProgress(progressBarColor: Colors.black12),
              ),
          );
        } else {
          docSnapshots.data.shuffle();
          if (docSnapshots.data.length > 9){
            docSnapshots.data.removeRange(9, docSnapshots.data.length - 1);
          }
          docSnapshots.data.forEach((doc){
            nearbyUsers.add(WebblenUser.fromMap(doc.data));
          });
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                //margin: EdgeInsets.symmetric(horizontal: 12.0),
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: new CarouselSlider(
                    items:  BuildTopUsers(context: context, currentUser: currentUser, top10NearbyUsers: nearbyUsers).buildTopUsers(),
                    height: 100.0,
                    viewportFraction: 0.3 ,
                    autoPlay: true,
                    autoPlayAnimationDuration: Duration(seconds: 10),
                    autoPlayCurve: Curves.linear,
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class StreamNumberOfNearbyUsers extends StatelessWidget {

  final double lat;
  final double lon;
  StreamNumberOfNearbyUsers({this.lat, this.lon});

  @override
  Widget build(BuildContext context) {

    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: lat, longitude: lon);
    CollectionReference userRef = Firestore.instance.collection("users");

    return StreamBuilder(
      stream: geo.collection(collectionRef: userRef)
          .within(center: center, radius: 20, field: 'location'),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> docSnapshots){
        if (!docSnapshots.hasData) {
          return Container();
        } else {
          return Fonts().textW700("${docSnapshots.data.length} People Nearby", 16.0, Colors.black, TextAlign.left);
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/models/local_ad.dart';
import 'package:webblen/widgets_home_tiles/community_activity_tile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:webblen/widgets_local_ads/local_ad_row.dart';

class StreamLocalAds extends StatelessWidget {

  final double lat;
  final double lon;

  StreamLocalAds({this.lat, this.lon});

  @override
  Widget build(BuildContext context) {

    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: lat, longitude: lon);
    CollectionReference userRef = Firestore.instance.collection("local_ads");

    return StreamBuilder(
      stream: geo.collection(collectionRef: userRef)
          .within(center: center, radius: 20, field: 'location'),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> docSnapshots) {
        List<LocalAd> random5Ads = [];
        if (!docSnapshots.hasData) {
          return Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(child: CustomLinearProgress(progressBarColor: FlatColors.webblenRed)),
          );
        } else {
          docSnapshots.data.shuffle();
          docSnapshots.data.forEach((doc){
            random5Ads.add(LocalAd.fromMap(doc.data));
          });
          List<Widget> ads = [];
          Widget adRow = Container();
          if (random5Ads.isNotEmpty){
            adRow = Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  //margin: EdgeInsets.symmetric(horizontal: 12.0),
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: CarouselSlider(
                      items:  BuildAds(context: context, random5Ads: random5Ads).buildRandom5Ads(),
                      height: 130,
                      viewportFraction: 0.5,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 10),
                      enlargeCenterPage: true,
                      //autoPlayAnimationDuration: Duration(seconds: 2),
                      //autoPlayCurve: Curves.ease,
                    ),
                  ),
                ),
              ],
            );
          }
          return adRow;
        }
      },
    );
  }
}

class BuildAds {

  final List<LocalAd> random5Ads;
  final BuildContext context;

  BuildAds({this.context, this.random5Ads});

  List buildRandom5Ads() {
    List<Widget> ads = List();
    for (int i = 0; i < random5Ads.length; i++) {
      ads.add(
          LocalAdRow(
              localAd: random5Ads[i],
          )
      );
    }
    return ads;
  }

}
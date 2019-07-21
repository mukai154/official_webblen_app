import 'package:flutter/material.dart';
import 'package:webblen/models/local_ad.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'ad_tile.dart';

class AdCarousel extends StatelessWidget {

  final List<LocalAd> ads;

  AdCarousel({this.ads});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: CarouselSlider(
          items:  BuildAds(context: context, ads: ads).build(),
          height: 120,
          viewportFraction: 0.5,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 10),
          enlargeCenterPage: true,
          //autoPlayAnimationDuration: Duration(seconds: 2),
          //autoPlayCurve: Curves.ease,
        ),
      ),
    );
  }
}

class BuildAds {

  final List<LocalAd> ads;
  final BuildContext context;

  BuildAds({this.context, this.ads});

  List build(){
    List<Widget> adTiles = List();
    for (int i = 0; i < ads.length; i++) {
      adTiles.add(
          AdTile(
            localAd: ads[i],
          )
      );
    }
    return adTiles;
  }

}
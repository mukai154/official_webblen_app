import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

class WebblenEventsTile extends StatelessWidget {

  final VoidCallback onTap;
  WebblenEventsTile({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          height: MediaQuery.of(context).size.height * 0.18,
          width: MediaQuery.of(context).size.width - 32.0,
          //margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/webblen_events_background.png"),
              fit: BoxFit.cover,
            ),
            boxShadow: ([
              BoxShadow(
                color: Colors.black12,
                blurRadius: 1.8,
                spreadRadius: 0.6,
                offset: Offset(0.0, 2.5),
              ),
            ]),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 16.0, top: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Shimmer.fromColors(
                  baseColor: FlatColors.webblenRed,
                  highlightColor: FlatColors.webblenPink,
                  child: Text(
                    'Webblen Events',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
                Fonts().textW500('Discounted Tickets and Pricing to Webblen Sponsored Events', 10.0, Colors.black87, TextAlign.left),
                //Fonts().textW700('Discover', 24.0, Colors.black, TextAlign.left),
              ],
            ),
          ),
      ),
    );
  }
}
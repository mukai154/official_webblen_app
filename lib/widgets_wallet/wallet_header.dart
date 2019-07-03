import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/widgets_common/common_button.dart';

class WalletHeader extends StatelessWidget {

  final double eventPoints;
  final double impactPoints;
  final VoidCallback purchaseWebblenAction;


  WalletHeader({this.eventPoints, this.impactPoints, this.purchaseWebblenAction});

  Widget _buildEventPointsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Material(
                    borderRadius: BorderRadius.circular(24.0),
                    color: FlatColors.webblenRed,
                    child: Padding(
                        padding: EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
                        child: Row(
                          children: <Widget>[
                            Image.asset("assets/images/transparent_logo_xxsmall.png", height: 20.0, width: 20.0),
                            SizedBox(width: 4.0),
                            Fonts().textW700('Webblen: ${eventPoints.toStringAsFixed(2)}', 18.0, Colors.white, TextAlign.center)
                          ],
                        ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline, size: 24.0, color: FlatColors.greenTeal),
                    onPressed: purchaseWebblenAction,
                  ),
                ],
              ),
              Fonts().textW500(" Tokens that can be transferred or traded at any time.", 14.0, FlatColors.darkGray, TextAlign.center),
              Fonts().textW500(" Webblen is needed to create new events and communities", 14.0, FlatColors.darkGray, TextAlign.center),
            ],
          ),
          // new Text(eventPoints.toStringAsFixed(2), style: Fonts.walletHeadTextStyle),
        ]
    );
  }

  Widget _buildImpactPointsRow() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Material(
                    borderRadius: BorderRadius.circular(24.0),
                    color: Colors.black12,
                    child: Padding(
                        padding: EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
                        child: Row(
                          children: <Widget>[
                            Icon(FontAwesomeIcons.bolt, size: 18.0, color: FlatColors.darkGray),
                            Fonts().textW700('Attendance Power: x1.00', 18.0, FlatColors.darkGray, TextAlign.center)
                          ],
                        ),
                    ),
                  ),
                ],
              ),
              Fonts().textW500(" A multiplier that gives you more control over event payouts.", 14.0, FlatColors.darkGray, TextAlign.center),
              Fonts().textW500(" The higher your AP, the more your attendance is worth.", 14.0, FlatColors.darkGray, TextAlign.center),
              Fonts().textW500(" Increase your AP by attending events regularly.", 14.0, FlatColors.darkGray, TextAlign.center),
            ],
          ),
          // new Text(eventPoints.toStringAsFixed(2), style: Fonts.walletHeadTextStyle),
        ]
    );
  }

    @override
    Widget build(BuildContext context) {

      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 8.0),
            _buildEventPointsRow(),
            SizedBox(height: 24.0),
            _buildImpactPointsRow(),
            SizedBox(height: 18.0),
            Row(
              children: <Widget>[
                SizedBox(width: 18.0),
                Fonts().textW500("Estimated Account Value: \$" + ((eventPoints + impactPoints) * 0.05).toStringAsFixed(2), 14.0, Colors.black38, TextAlign.left),
              ],
            ),
            SizedBox(height: 16.0),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//              children: <Widget>[
////                sendButton(),
////                powerUpButton()
//              ],
//            ),
//            SizedBox(height: 32.0),
          ],
        ),
      );
  }



}

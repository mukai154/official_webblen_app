import 'package:flutter/material.dart';
import 'package:webblen/widgets_common/common_custom_alert.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/widgets_common/common_progress.dart';


class RewardInfoDialog extends StatelessWidget {
  final String rewardTitle;
  final String rewardDescription;
  final String rewardImageURL;
  final String rewardCost;
  final VoidCallback purchaseAction;
  final VoidCallback dismissAction;
  RewardInfoDialog({this.rewardTitle, this.rewardDescription, this.rewardImageURL, this.purchaseAction, this.dismissAction, this.rewardCost});

  @override
  Widget build(BuildContext context) {
    return new CustomAlertDialog(
      content: new Container(
        width: 260.0,
        height: 300.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius:
          new BorderRadius.all(new Radius.circular(32.0)),
        ),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // dialog centre
              new Container(
                child: Column(
                  children: <Widget>[
                    Text(rewardTitle, style: Fonts.alertDialogHeader, textAlign: TextAlign.center),
                    SizedBox(height: 8.0),
                    Text(rewardDescription, style: Fonts.alertDialogBody, textAlign: TextAlign.center),
                    SizedBox(height: 16.0),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 130.0,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.0, left: 8.0, right: 8.0, bottom: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset("assets/images/webblen_coin", height: 20.0, width: 20.0),
                            SizedBox(width: 4.0),
                            Fonts().textW700('$rewardCost', 18.0, Colors.white, TextAlign.center)
                          ],
                          ),
                        ),
                    )
                    ],
                ),
              ),
            SizedBox(height: 14.0),
           // ),

            // dialog bottom
            Container(
              child: Column(
                children: <Widget>[
                  CustomColorButton(
                    text: "Purchase",
                    textColor: Colors.white,
                    backgroundColor: FlatColors.darkMountainGreen,
                    height: 40.0,
                    width: 200.0,
                    onPressed: purchaseAction
                  ),
                  CustomColorButton(
                    text: "Cancel",
                    textColor: FlatColors.londonSquare,
                    backgroundColor: Colors.white,
                    height: 40.0,
                    width: 200.0,
                    onPressed: dismissAction
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RewardConfirmPurchaseDialog extends StatelessWidget {
  final String rewardTitle;
  final String rewardDescription;
  final String rewardCost;
  final String rewardImageURL;
  final VoidCallback confirmAction;
  final VoidCallback cancelAction;
  final bool purchaseIsLoading;
  RewardConfirmPurchaseDialog({this.rewardTitle, this.rewardDescription, this.rewardCost, this.rewardImageURL, this.confirmAction, this.cancelAction, this.purchaseIsLoading});

  @override
  Widget build(BuildContext context) {
    return new CustomAlertDialog(
      content: new Container(
        width: 260.0,
        height: 250.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius:
          new BorderRadius.all(new Radius.circular(32.0)),
        ),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[



            // dialog centre
            SizedBox(height: 16.0),
            new Container(
              child: Column(
                children: <Widget>[
                  Text("Purchase $rewardTitle Reward for $rewardCost Webblen?", style: Fonts.alertDialogHeader, textAlign: TextAlign.center),

                ],
              ),
            ),
            SizedBox(height: 16.0),
            // ),

            // dialog bottom
            Container(
              child: Column(
                children: <Widget>[
                  purchaseIsLoading ? CustomCircleProgress(20.0, 20.0, 20.0, 20.0, FlatColors.webblenRed)
                  : CustomColorButton(
                    text: "Confirm",
                    textColor: Colors.white,
                    backgroundColor: FlatColors.darkMountainGreen,
                    height: 45.0,
                    width: 200.0,
                    onPressed: confirmAction
                  ),
                  purchaseIsLoading ? SizedBox()
                  : CustomColorButton(
                    text: "Cancel",
                    textColor: FlatColors.londonSquare,
                    backgroundColor: Colors.white,
                    height: 45.0,
                    width: 200.0,
                    onPressed: cancelAction
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RewardWalletDialog extends StatelessWidget {
  final String rewardTitle;
  final String rewardDescription;
  final String rewardImageURL;
  final String rewardCost;
  final VoidCallback redeemAction;
  final VoidCallback dismissAction;
  RewardWalletDialog({this.rewardTitle, this.rewardDescription, this.rewardImageURL, this.redeemAction, this.dismissAction, this.rewardCost});

  @override
  Widget build(BuildContext context) {
    return new CustomAlertDialog(
      content: new Container(
        width: 260.0,
        height: 220.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius:
          new BorderRadius.all(new Radius.circular(32.0)),
        ),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child:ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: FadeInImage.assetNetwork(placeholder: "assets/gifs/loading.gif", image: rewardImageURL, height: 60.0, width: 60.0, fit: BoxFit.contain,),
              ) ,
            ),

            // dialog centre
            SizedBox(height: 16.0),
            new Container(
              child: Column(
                children: <Widget>[
                  Text(rewardTitle, style: Fonts.alertDialogHeader, textAlign: TextAlign.center),
                  Text(rewardDescription, style: Fonts.alertDialogBody, textAlign: TextAlign.center),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
            SizedBox(height: 14.0),
            // ),

            // dialog bottom
            Container(
              child: Column(
                children: <Widget>[
                  CustomColorButton(
                    text: "Redeem",
                    textColor: Colors.white,
                    backgroundColor: FlatColors.darkMountainGreen,
                    height: 45.0,
                    width: 200.0,
                    onPressed: redeemAction
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RewardRedemptionDialog extends StatelessWidget {
  final String rewardTitle;
  final String rewardDescription;
  final String rewardCost;
  final String rewardImageURL;
  final VoidCallback confirmAction;
  final VoidCallback cancelAction;
  RewardRedemptionDialog({this.rewardTitle, this.rewardDescription, this.rewardCost, this.rewardImageURL, this.confirmAction, this.cancelAction});

  @override
  Widget build(BuildContext context) {
    return new CustomAlertDialog(
      content: new Container(
        width: 260.0,
        height: 220.0,
        decoration: new BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius:
          new BorderRadius.all(new Radius.circular(32.0)),
        ),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 16.0),
            new Container(
              child: Column(
                children: <Widget>[
                  Text("Redeem $rewardTitle's Reward?", style: Fonts.alertDialogHeader, textAlign: TextAlign.center),
//                  SizedBox(height: 8.0),
//                  Text("for ${rewardCost} points?", style: Fonts.alertDialogBody, textAlign: TextAlign.center),
                ],
              ),
            ),
            SizedBox(height: 30.0),
            // ),

            // dialog bottom
            Container(
              child: Column(
                children: <Widget>[
                  CustomColorButton(
                        text: "Confirm",
                        textColor: Colors.white,
                        backgroundColor: FlatColors.darkMountainGreen,
                        height: 45.0,
                        width: 200.0,
                        onPressed: confirmAction
                      ),
                   CustomColorButton(
                        text: "Cancel",
                        textColor: FlatColors.londonSquare,
                        backgroundColor: Colors.white,
                        height: 45.0,
                        width: 200.0,
                        onPressed: cancelAction
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


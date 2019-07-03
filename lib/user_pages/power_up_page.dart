import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/firebase_services/user_data.dart';
import 'package:webblen/widgets_common/common_progress.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'dart:async';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/models/webblen_user.dart';

class PowerUpPage extends StatefulWidget {

  final WebblenUser currentUser;
  PowerUpPage({this.currentUser});

  @override
  _PowerUpPageState createState() => _PowerUpPageState();
}

class _PowerUpPageState extends State<PowerUpPage> {

  bool isPoweringUp = false;
  double powerUpAmount = 0.10;
  double availablePointsForPowerUp = 0.0;

  // ** APP BAR
  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Color(0xFFF9F9F9),
      title: Fonts().textW800('fix', 24.0, FlatColors.darkGray, TextAlign.center),
      leading: BackButton(color: FlatColors.londonSquare),
      actions: <Widget>[
        IconButton(
          icon: Icon(FontAwesomeIcons.questionCircle, size: 20.0,
              color: FlatColors.londonSquare),
          onPressed: () {powerUpHintAlert(context);},
        ),
      ],
    );
  }

  Future<bool> powerUpAlert(BuildContext context) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Container(
              child: Column(
                children: <Widget>[
                  Image.asset("assets/images/power_up.png", height: 45.0, width: 45.0),
                  SizedBox(height: 8.0),
                  Fonts().textW800('fix', 24.0, FlatColors.darkGray, TextAlign.center),
                  //Text("Increase Impact by ${powerUpAmount.toStringAsFixed(2)}?", style: Fonts.alertDialogHeader, textAlign: TextAlign.center),
                ],
              ),
            ),
            content: Fonts().textW800('fix', 24.0, FlatColors.darkGray, TextAlign.center),
            //new Text("Converting your points into impact increases the value of your attencance and the amount of points you earn from future events", style: Fonts.alertDialogBody, textAlign: TextAlign.center),
            actions: <Widget>[
              new FlatButton(
                child: Fonts().textW800('fix', 24.0, FlatColors.darkGray, TextAlign.center),
                //new Text("No", style: Fonts.alertDialogAction),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: Fonts().textW800('fix', 24.0, FlatColors.darkGray, TextAlign.center),
                //new Text("Yes", style: Fonts.alertDialogAction),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    isPoweringUp = true;
                    powerUp();
                  });
                },
              ),
            ],
          );
        });
  }

  powerUpHintAlert(BuildContext context){
    ShowAlertDialogService().showInfoDialog(context, "What is Powering Up?", 'Powering up is converting your points into "impact". Impact increase the value of your attendance at events.');
  }

  powerUp(){
    if (availablePointsForPowerUp < 0.1){
      ShowAlertDialogService().showFailureDialog(context, "Power Up Not Available", "You Need At Least 0.1 Points to Level Up");
    } else {
      ShowAlertDialogService().showLoadingDialog(context);
      UserDataService().powerUpPoints(widget.currentUser.uid, powerUpAmount).then((val){
        availablePointsForPowerUp -= powerUpAmount;
        isPoweringUp = false;
        Navigator.of(context).pop();
        ShowAlertDialogService().showSuccessDialog(context, "Powered Up!", "Your Impact has Increased by ${powerUpAmount.toStringAsFixed(2)}");
        setState(() {});
      });
    }
  }

  Widget _buildPowerSlider(){
    return Slider(
      inactiveColor: FlatColors.londonSquare,
      activeColor: FlatColors.lightCarribeanGreen,
      value: availablePointsForPowerUp < 0.1 ? 0.0 : powerUpAmount,
      min: availablePointsForPowerUp < 0.1 ? 0.0 : 0.1,
      max: availablePointsForPowerUp < 0.1 ? 0.0 : availablePointsForPowerUp,
      //divisions: 39,
      label: availablePointsForPowerUp < 0.1 ? 'Not Enough Points for Power Up': '${powerUpAmount.toStringAsFixed(2)}',
      onChanged: (double value) {
        setState(() {
          powerUpAmount = value;
        });
      },
    );
  }

  Widget _buildBody(){
    return new Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: new Column /*or Column*/(
        children: <Widget>[
          SizedBox(height: 80.0),
          availablePointsForPowerUp < 0.1 ? Fonts().textW500("Not Enough Points for Power Up", 18.0, FlatColors.londonSquare, TextAlign.center)
              : Fonts().textW500("Points Available: ${availablePointsForPowerUp.toStringAsFixed(2)}", 18.0, FlatColors.londonSquare, TextAlign.center),
          SizedBox(height: 16.0),
          availablePointsForPowerUp < 0.1 ? SizedBox()
          : Fonts().textW800('fix', 24.0, FlatColors.darkGray, TextAlign.center),//Text("Power Up Total: ${powerUpAmount.toStringAsFixed(2)}", style: Fonts.bodyTextStyleGray),
          SizedBox(height: 16.0),
          new Container(
            height: 85.0,
            width: 85.0,
            child: isPoweringUp ? CustomCircleProgress(60.0, 60.0, 30.0, 30.0, FlatColors.londonSquare)
                : new Image.asset("assets/images/power_up.png", height: 100.0, width: 100.0),
          ),
          SizedBox(height: 16.0),
          _buildPowerSlider(),
          SizedBox(height: 16.0),
          availablePointsForPowerUp < 0.1 ? SizedBox()
          : CustomColorButton(
                    text: "Power Up",
                    textColor: Colors.white,
                    backgroundColor: FlatColors.darkMountainGreen,
                    height: 45.0,
                    width: 200.0,
                    onPressed: () => powerUpAlert(context)
                  ),
        ],
      ),
    );
  }

  @override
  void initState() {
      // TODO: implement initState
      super.initState();
      availablePointsForPowerUp = widget.currentUser.eventPoints;
      setState(() {});
    }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody()
    );
  }
}
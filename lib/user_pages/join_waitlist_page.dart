import 'package:flutter/material.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'dart:async';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/services_general/services_location.dart';
import 'package:webblen/widgets_common/common_appbar.dart';


class JoinWaitlistPage extends StatefulWidget {

  final WebblenUser currentUser;
  JoinWaitlistPage({this.currentUser});

  @override
  _JoinWaitlistPageState createState() => _JoinWaitlistPageState();
}

class _JoinWaitlistPageState extends State<JoinWaitlistPage> {

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  double lat;
  double lon;
  bool isLoading = false;
  bool submitEmail = false;
  String email;

  var phoneMaskController = MaskedTextController(mask: '+0 000-000-0000');
  String phoneNo;
  String zipCode;

  setInfoType(){
    FocusScope.of(context).requestFocus(new FocusNode());
    if (submitEmail){
      setState(() {
        submitEmail = false;
      });
    } else {
      setState(() {
        submitEmail = true;
      });
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<Null> validateAndSubmit() async {
    ShowAlertDialogService().showLoadingDialog(context);
    if (validateAndSave()) {
      if (email == null && phoneNo == null){
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(context, "Info Missing", "Please Enter Your Email or Phone Number to Join Our Waitlist");
      } else if (lat == null || lon == null){
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(context, "Location Missing", "Please Enable Location Services to Join Our Waitlist");
      } else {
        UserDataService().joinWaitList(widget.currentUser.uid, lat, lon, email, phoneNo, zipCode).then((error){
          Navigator.of(context).pop();
          if (error.isEmpty){
            ShowAlertDialogService().showActionSuccessDialog(
                context,
                "We'll Let You Know When We're In Your Area!",
                "Be sure to checkout our Instagram and Twitter for further news ",
                    () => PageTransitionService(context: context).transitionToRootPage()
            );
          } else {
            ShowAlertDialogService().showFailureDialog(context, 'There was an issue!', error);
          }
        });
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    LocationService().getCurrentLocation(context).then((res){
      lat = res.latitude;
      lon = res.longitude;
      LocationService().getZipFromLatLon(lat, lon).then((res){
        setState(() {
          zipCode = res;
        });
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    // **EMAIL FIELD
    final emailField = Padding(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        style: TextStyle(color: FlatColors.darkGray, fontWeight: FontWeight.w600),
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        validator: (value) => value.isEmpty ? 'Email Cannot be Empty' : null,
        onSaved: (value) => email = value,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.email, color: FlatColors.darkGray),
          hintText: "Email",
          hintStyle: TextStyle(color: Colors.black26),
          errorStyle: TextStyle(color: Colors.red),
          contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        ),
      ),
    );

    // **PHONE FIELD
    final phoneField = Padding(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: new TextFormField(
        controller: phoneMaskController,
        style: TextStyle(color: FlatColors.darkGray, fontWeight: FontWeight.w600),
        keyboardType: TextInputType.number,
        autofocus: false,
        validator: (value) => value.isEmpty ? 'Phone Cannot be Empty' : null,
        onSaved: (value) => phoneNo = value,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.phone, color: FlatColors.darkGray),
          hintText: "+0 000-000-000",
          hintStyle: TextStyle(color: Colors.black26),
          errorStyle: TextStyle(color: Colors.red),
          contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        ),
      ),
    );

    // **LOGIN BUTTON
    final submitButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 26.0),
      child: Material(
        elevation: 5.0,
        color: FlatColors.goodNight,
        borderRadius: BorderRadius.circular(25.0),
        child: InkWell(
          onTap: () => validateAndSubmit(),
          child: Container(
            height: 45.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Fonts().textW500('Join Waitlist', 14.0, Colors.white, TextAlign.center)
              ],
            ),
          ),
        ),
      ),
    );

    // **EMAIL/PHONE BUTTON
    final submitEmailButton = CustomColorIconButton(
      icon: Icon(FontAwesomeIcons.envelope, color: FlatColors.darkGray, size: 18.0),
      text: "Be Notified By Email",
      textColor: FlatColors.darkGray,
      backgroundColor: Colors.white,
      height: 45.0,
      width: MediaQuery.of(context).size.width * 0.85,
      onPressed: () => setInfoType(),
    );

    final submitPhoneButton = CustomColorIconButton(
      icon: Icon(FontAwesomeIcons.mobileAlt, color: FlatColors.darkGray, size: 18.0),
      text: "Be Notified By Phone",
      textColor: FlatColors.darkGray,
      backgroundColor: Colors.white,
      height: 45.0,
      width: MediaQuery.of(context).size.width * 0.85,
      onPressed: () => setInfoType(),
    );

    final emailForm = Form(
      key: formKey,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Fonts().textW500('Enter Email Address', 18.0, FlatColors.darkGray, TextAlign.center),
          emailField,
          submitButton,
          submitEmail ? submitPhoneButton : submitEmailButton
        ],
      ),
    );

    final phoneAuthForm = Form(
      key: formKey,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Fonts().textW500('Enter Phone Number', 18.0, FlatColors.darkGray, TextAlign.center),
          phoneField,
          submitButton,
          submitEmail ? submitPhoneButton : submitEmailButton
        ],
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: WebblenAppBar().basicAppBar("Join Waitlist"),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child:  submitEmail ? emailForm : phoneAuthForm,
        ),
      ),
    );
  }
}
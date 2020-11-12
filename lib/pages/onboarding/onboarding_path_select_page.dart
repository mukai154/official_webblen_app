import 'dart:ui';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/constants/strings.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/services/device_permissions.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/containers/text_field_container.dart';
import 'package:webblen/widgets/common/state/progress_indicator.dart';

class OnboardingPathSelectPage extends StatefulWidget {
  @override
  _OnboardingPathSelectPageState createState() => _OnboardingPathSelectPageState();
}

class _OnboardingPathSelectPageState extends State<OnboardingPathSelectPage> {
  bool isLoading = false;
  final introKey = GlobalKey<IntroductionScreenState>();
  final formKey = GlobalKey<FormState>();
  TextEditingController textEditingController = TextEditingController();
  String emailAddress;
  int imgFlex = 3;
  bool showNextButton = true;
  bool showSkipButton = false;

  bool freezeSwipe = false;
  bool locationError = false;
  bool hasLocation = false;
  String areaName;
  String uid;

  //Email
  validateAndSubmitEmailAddress() async {
    FormState formState = formKey.currentState;
    formState.save();
    print(emailAddress);
    if (!Strings().isEmailValid(emailAddress)) {
      showAlertDialog(
        context: context,
        message: "Invalid Email Address",
        barrierDismissible: true,
        actions: [
          AlertDialogAction(label: "Ok", isDefaultAction: true),
        ],
      );
    } else {
      WebblenUserData().setAssociatedEmailAddress(uid, emailAddress);
      introKey.currentState.next();
    }
  }

  //Location Permissions
  checkPermissions() async {
    DevicePermissions().checkLocationPermissions().then((locationPermissions) async {
      if (locationPermissions == 'PermissionStatus.unknown') {
        String permissions = await DevicePermissions().requestPermssion();
        if (permissions == 'PermissionStatus.denied') {
          showOkAlertDialog(context: context, title: "Location Disabled", message: "Open Your App Settings to Enable Location Services");
          locationError = true;
          isLoading = false;
          setState(() {});
        } else {
          loadLocation();
        }
      } else if (locationPermissions == 'PermissionStatus.denied') {
        showOkAlertDialog(context: context, title: "Location Error", message: "Open Your App Settings to Enable Location Services");
        locationError = true;
        hasLocation = false;
        isLoading = false;
        setState(() {});
      } else {
        loadLocation();
      }
    });
  }

  Future<Null> loadLocation() async {
    LocationData location = await LocationService().getCurrentLocation(context);
    if (location != null) {
      IntroductionScreenState screenState = introKey.currentState;
      screenState.next();
      locationError = false;
      hasLocation = true;
      LocationService().getCityNameFromLatLon(location.latitude, location.longitude).then((res) {
        areaName = res;
        isLoading = false;
        setState(() {});
      });
    } else {
      locationError = true;
      hasLocation = false;
      isLoading = false;
      setState(() {});
    }
  }

  ////Navigation
  transitionToEventHostPath() {
    PageTransitionService(context: context).transitionToEventHostPath();
  }

  transitionToStreamerPath() {
    PageTransitionService(context: context).transitionToStreamerPath();
  }

  transitionToAttendeeViewerPath() {
    PageTransitionService(context: context).transitionToAttendeeViewerPath();
  }

  Widget onboardingImage(String assetName) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Image.asset(
          'assets/images/$assetName.png',
          height: 200,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }

  //Initial Pages
  PageViewModel initialPage(PageDecoration pageDecoration) {
    return PageViewModel(
      titleWidget: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "We're Excited to Have You!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
            )
          ],
        ),
      ),
      bodyWidget: Text(
        "Let's answer a few questions to help get you going in your community",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18.0, height: 1.5),
      ),
      image: onboardingImage('team_arrow'),
      decoration: pageDecoration,
    );
  }

  PageViewModel associatedEmailPage(PageDecoration pageDecoration) {
    return PageViewModel(
      titleWidget: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "What's Your Email Address?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
            )
          ],
        ),
      ),
      bodyWidget: Text(
        "Just In Case You Lose Access to Your Account",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18.0, height: 1.5),
      ),
      footer: Column(
        children: [
          Form(
            key: formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextFieldContainer(
                height: 50,
                child: TextFormField(
                  controller: textEditingController,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: Colors.black,
                  validator: (val) => val.isEmpty ? 'Field Cannot be Empty' : null,
                  maxLines: null,
                  onSaved: (val) {
                    emailAddress = val.trim();
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: "Email Address",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          CustomColorButton(
            text: "Set Email Address",
            textColor: Colors.black,
            backgroundColor: Colors.white,
            width: 300.0,
            height: 45.0,
            onPressed: () => validateAndSubmitEmailAddress(),
          ),
        ],
      ),
      image: onboardingImage('phone_email'),
      decoration: pageDecoration,
    );
  }

  PageViewModel locationPermissionPage(PageDecoration pageDecoration) {
    return PageViewModel(
      titleWidget: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Where Are You?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
            )
          ],
        ),
      ),
      bodyWidget: Text(
        "Please share your location to take part in what's happening in your area",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18.0, height: 1.5),
      ),
      image: onboardingImage('person_map'),
      decoration: pageDecoration,
      footer: Container(
        child: Column(
          children: [
            isLoading
                ? CustomCircleProgress(40, 40, 40, 40, CustomColors.webblenRed)
                : CustomColorButton(
                    text: locationError ? "Try Again" : "Enable Location",
                    textColor: Colors.black,
                    backgroundColor: Colors.white,
                    width: 300.0,
                    height: 45.0,
                    onPressed: () => checkPermissions(),
                  ),
            locationError
                ? Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: GestureDetector(
                      onTap: () => openAppSettings(),
                      child: Text(
                        "Open App Settings",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blue, fontSize: 16.0, fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  PageViewModel selectExperiencePage(PageDecoration pageDecoration) {
    return PageViewModel(
      titleWidget: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "The Culture of $areaName\nis in Your Hands",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
            )
          ],
        ),
      ),
      bodyWidget: Text(
        "How Would You Like to Be Involved?",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18.0, height: 1.5),
      ),
      image: onboardingImage('city_buildings'),
      decoration: pageDecoration,
      footer: Container(
        child: Column(
          children: [
            CustomColorButton(
              text: "Host Live & Virtual Events",
              textColor: Colors.black,
              backgroundColor: Colors.white,
              width: 300.0,
              height: 45.0,
              onPressed: () => transitionToEventHostPath(),
            ),
            SizedBox(height: 16),
            CustomColorButton(
              text: "Livestream Video",
              textColor: Colors.black,
              backgroundColor: Colors.white,
              width: 300.0,
              height: 45.0,
              onPressed: () => transitionToStreamerPath(),
            ),
            SizedBox(height: 16),
            CustomColorButton(
              text: "Find Events, Streams, & Communities",
              textColor: Colors.black,
              backgroundColor: Colors.white,
              width: 300.0,
              height: 45.0,
              onPressed: () => transitionToAttendeeViewerPath(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    BaseAuth().getCurrentUserID().then((userID) {
      setState(() {
        uid = userID;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    PageDecoration pageDecoration = PageDecoration(
      contentPadding: EdgeInsets.all(0),
      titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
      bodyTextStyle: TextStyle(fontSize: 16.0),
      titlePadding: EdgeInsets.only(top: 16.0, bottom: 8.0, left: 16, right: 16),
      imageFlex: imgFlex,
      bodyFlex: 3,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
    );

    return IntroductionScreen(
      key: introKey,
      onChange: (pageNum) {
        if (pageNum == 0) {
          showNextButton = true;
        } else {
          showNextButton = false;
        }
        if (pageNum == 1) {
          showSkipButton = true;
        } else {
          showSkipButton = false;
        }
        if (pageNum == 0 || pageNum == 1 || pageNum == 2) {
          imgFlex = 3;
        } else {
          imgFlex = 2;
        }
        setState(() {});
      },
      freeze: true,
      onDone: () {},
      onSkip: () {
        introKey.currentState.next();
      },
      showSkipButton: showSkipButton,
      showNextButton: showNextButton,
      skipFlex: 0,
      nextFlex: 0,
      skip: Text('Skip', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      next: Icon(FontAwesomeIcons.arrowRight, size: 24.0, color: Colors.black),
      done: Container(),
      dotsDecorator: DotsDecorator(
        size: Size(0.0, 0.0),
        color: Colors.white,
        activeColor: Colors.white,
        activeSize: Size(0.0, 0.0),
      ),
      pages: [
        initialPage(pageDecoration),
        associatedEmailPage(pageDecoration),
        locationPermissionPage(pageDecoration),
        selectExperiencePage(pageDecoration),
      ],
    );
  }
}

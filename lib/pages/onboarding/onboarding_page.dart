import 'dart:io';
import 'dart:ui';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/services/device_permissions.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/state/progress_indicator.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => new _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  String stripeConnectURL;
  bool isLoading = false;
  final introKey = GlobalKey<IntroductionScreenState>();
  bool locationError = false;
  bool hasLocation = false;
  String areaName;
  String onboardPath;
  bool showNextButton = true;
  bool freezeSwipe = false;
  File userImage;
  String uid;
  String username;
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final usernameFormKey = GlobalKey<FormState>();
  final userSetupScaffoldKey = GlobalKey<ScaffoldState>();

  void _onIntroEnd(context) {
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (_) => HomePage()),
    // );
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

  //Experience Select
  continueEventHostPath() {
    onboardPath = "host";
    setState(() {});
    IntroductionScreenState screenState = introKey.currentState;
    screenState.next();
  }

  continueLivestreamPath() {
    onboardPath = "streamer";
    setState(() {});
    IntroductionScreenState screenState = introKey.currentState;
    screenState.next();
  }

  continueAttendeeViewerPath() {
    onboardPath = "attendee";
    setState(() {});
    IntroductionScreenState screenState = introKey.currentState;
    screenState.next();
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
        ));
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
              text: "Host Live/Virtual Events",
              textColor: Colors.black,
              backgroundColor: Colors.white,
              width: 300.0,
              height: 45.0,
              onPressed: () => continueEventHostPath(),
            ),
            SizedBox(height: 16),
            CustomColorButton(
              text: "Livestream Video",
              textColor: Colors.black,
              backgroundColor: Colors.white,
              width: 300.0,
              height: 45.0,
              onPressed: () => print('pressed'),
            ),
            SizedBox(height: 16),
            CustomColorButton(
              text: "Attend Events and Watch Streams",
              textColor: Colors.black,
              backgroundColor: Colors.white,
              width: 300.0,
              height: 45.0,
              onPressed: () => print('pressed'),
            ),
          ],
        ),
      ),
    );
  }

  ///ONBOARDING PATHS
  //Even host
  PageViewModel initialEventHostPage(PageDecoration pageDecoration) {
    return PageViewModel(
      title: "Events Just Got A Lot More Fun",
      body: "Webblen Offers the Best Tools, Benefits, and Resources to Make Your Event a Success",
      image: onboardingImage('party'),
      decoration: pageDecoration,
    );
  }

  PageViewModel sellTicketsForFreePage(PageDecoration pageDecoration) {
    return PageViewModel(
      title: "Will You Monetize Your Events?",
      body: "Selling tickets and taking donations are two examples of how your event can earn you money.",
      image: onboardingImage('online_payment'),
      decoration: pageDecoration,
      footer: Container(
        child: Column(
          children: [
            CustomColorButton(
              text: "Yes, Of Course",
              textColor: Colors.black,
              backgroundColor: Colors.white,
              width: 300.0,
              height: 45.0,
              onPressed: () => continueEventHostPath(),
            ),
            SizedBox(height: 16),
            CustomColorButton(
              text: "No, All of My Events Are 100% Free",
              textColor: Colors.black,
              backgroundColor: Colors.white,
              width: 300.0,
              height: 45.0,
              onPressed: () => print('pressed'),
            ),
          ],
        ),
      ),
    );
  }

  PageViewModel createHostEarningsAccountPage(PageDecoration pageDecoration) {
    return PageViewModel(
      image: onboardingImage('wallet'),
      decoration: pageDecoration,
      titleWidget: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Create a Webblen Earnings Account",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
            )
          ],
        ),
      ),
      bodyWidget: Text(
        "• Sell Event Tickets for Free"
        "\n• Access Funds From Ticket Sales with Same-Day Deposits"
        "\n• Accept donations From Event Attendees",
        textAlign: TextAlign.left,
        style: TextStyle(fontSize: 14.0, height: 1.5),
      ),
      footer: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("stripe").doc(uid).snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData || snapshot.data.data() == null)
              return Column(
                children: [
                  CustomColorButton(
                    text: "Create Earnings Account",
                    textColor: Colors.black,
                    backgroundColor: Colors.white,
                    width: 300.0,
                    height: 45.0,
                    onPressed: () => OpenUrl().launchInWebViewOrVC(context, stripeConnectURL),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: GestureDetector(
                      onTap: () => openAppSettings(),
                      child: Text(
                        "I'll Do This Later",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black87, fontSize: 16.0, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              );
            return Column(
              children: [
                Text(
                  snapshot.data.data()['verified'] == "pending" || snapshot.data.data()['verified'] == "unverified"
                      ? "Your Earnings Account is Under Review"
                      : "Your Earnings Account Has Been Approved!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: snapshot.data.data()['verified'] == "pending" || snapshot.data.data()['verified'] == "unverified"
                          ? Colors.black54
                          : CustomColors.darkMountainGreen,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 16.0),
                CustomColorButton(
                  text: "Continue",
                  textColor: Colors.black,
                  backgroundColor: Colors.white,
                  width: 300.0,
                  height: 45.0,
                  onPressed: () => checkPermissions(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PageViewModel scanForEventTickets(PageDecoration pageDecoration) {
    return PageViewModel(
      title: "Check-Ins Made Easy",
      body: "Scan In Attendees Easily with Our In-App Scanner",
      image: onboardingImage('qr_code'),
      decoration: pageDecoration,
    );
  }

  PageViewModel socialAccountsPage(PageDecoration pageDecoration) {
    return PageViewModel(
      titleWidget: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Have Any Other Social Accounts?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
            )
          ],
        ),
      ),
      body: "Connecting Additional Accounts Make it Easier to Share Your Events and Streams with Different Audiences",
      image: onboardingImage('social_media'),
      decoration: pageDecoration,
    );
  }

  @override
  void initState() {
    super.initState();
    BaseAuth().getCurrentUserID().then((userID) {
      setState(() {
        uid = userID;
        stripeConnectURL = "https://us-central1-webblen-events.cloudfunctions.net/connectStripeCustomAccount?uid=$uid";
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
      imageFlex: 1,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      //imagePadding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
    );
    return IntroductionScreen(
      key: introKey,
      freeze: freezeSwipe,
      onChange: (pageNum) {
        print(pageNum);
        if (pageNum == 1 || pageNum == 2) {
          freezeSwipe = true;
          showNextButton = false;
        } else if (pageNum == 3) {
          freezeSwipe = false;
          showNextButton = true;
        }
        setState(() {});
      },
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: false,
      showNextButton: showNextButton,
      skipFlex: 0,
      nextFlex: 0,
      skip: Text('Skip'),
      next: Icon(FontAwesomeIcons.arrowRight, size: 24.0, color: Colors.black),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: Size(10.0, 10.0),
        color: CustomColors.iosOffWhite,
        activeColor: CustomColors.webblenRed,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      pages: [
        initialPage(pageDecoration),
        locationPermissionPage(pageDecoration),
        selectExperiencePage(pageDecoration),
        onboardPath == 'host'
            ? initialEventHostPage(pageDecoration)
            : onboardPath == 'streamer'
                ? initialEventHostPage(pageDecoration)
                : initialEventHostPage(pageDecoration),
        onboardPath == 'host'
            ? sellTicketsForFreePage(pageDecoration)
            : onboardPath == 'streamer'
                ? initialEventHostPage(pageDecoration)
                : initialEventHostPage(pageDecoration),
        onboardPath == 'host'
            ? createHostEarningsAccountPage(pageDecoration)
            : onboardPath == 'streamer'
                ? initialEventHostPage(pageDecoration)
                : initialEventHostPage(pageDecoration),
        onboardPath == 'host'
            ? socialAccountsPage(pageDecoration)
            : onboardPath == 'streamer'
                ? initialEventHostPage(pageDecoration)
                : initialEventHostPage(pageDecoration),
      ],
    );
  }
}

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
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

  Widget onboardingImage(String assetName) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Image.asset(
          'assets/images/$assetName.png',
          height: 300,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }

  //Pages
  PageViewModel page1(PageDecoration pageDecoration) {
    return PageViewModel(
      titleWidget: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Welcome to Webblen",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
            )
          ],
        ),
      ),
      bodyWidget: Text(
        'Get Paid to be Involved \n In Your Community',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
      ),
      image: onboardingImage('modern_city'),
      decoration: pageDecoration,
    );
  }

  PageViewModel page2(PageDecoration pageDecoration) {
    return PageViewModel(
      titleWidget: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Influence the Culture\nof Your Area",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
            )
          ],
        ),
      ),
      bodyWidget: Text(
        "Share your events, ideas, and talents\ndirectly with the people around you",
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
      ),
      image: onboardingImage('conversation'),
      decoration: pageDecoration,
    );
  }

  PageViewModel page3(PageDecoration pageDecoration) {
    return PageViewModel(
      titleWidget: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "The Best Tools to Engage Your Community",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
            )
          ],
        ),
      ),
      bodyWidget: Text(
        "• Post Messages and Photos to Local Audiences"
        "\n• Stream Live Directly to Everyone Around You"
        "\n• Sell Tickets to Your Events and Virtual Streams"
        "\n• And More!",
        textAlign: TextAlign.left,
        style: TextStyle(fontSize: 14.0, height: 1.5),
      ),
      image: onboardingImage('mobile_people_group'),
      decoration: pageDecoration,
    );
  }

  PageViewModel page4(PageDecoration pageDecoration) {
    return PageViewModel(
      titleWidget: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Get Paid to Be Involved",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
            )
          ],
        ),
      ),
      bodyWidget: Text(
        'Whether you attend events, watch streams, or comment on posts, Webblen pays and rewards your involvement.',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
      ),
      image: onboardingImage('wallet'),
      decoration: pageDecoration,
    );
  }

  PageViewModel page5(PageDecoration pageDecoration) {
    return PageViewModel(
      titleWidget: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Get Started!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700),
            )
          ],
        ),
      ),
      bodyWidget: Column(
        children: [
          Text(
            'Change the Way You Get Involved\n and Enjoy it Like Never Before!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
          ),
          SizedBox(height: 16.0),
          CustomColorButton(
            text: 'Get Started',
            textColor: Colors.black,
            backgroundColor: Colors.white,
            height: 45.0,
            width: 200.0,
            onPressed: () => PageTransitionService(context: context).transitionToLoginPage(),
          ),
        ],
      ),
      image: onboardingImage('balloon_person'),
      decoration: pageDecoration,
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
      bodyFlex: 2,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
    );

    return IntroductionScreen(
      key: introKey,
      onDone: () {},
      showSkipButton: showSkipButton,
      showNextButton: showNextButton,
      skipFlex: 0,
      nextFlex: 0,
      skip: Text('Skip', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      next: Icon(FontAwesomeIcons.arrowRight, size: 24.0, color: Colors.black),
      done: Container(),
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
        page1(pageDecoration),
        page2(pageDecoration),
        page3(pageDecoration),
        page4(pageDecoration),
        page5(pageDecoration),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:webblen/constants/custom_colors.dart';
// import 'package:webblen/services_general/service_page_transitions.dart';
//
// class SplashPage extends StatefulWidget {
//   @override
//   _SplashPageState createState() => _SplashPageState();
// }
//
// class _SplashPageState extends State<SplashPage> {
//   final int _numPages = 5;
//   final PageController _pageController = PageController(initialPage: 0);
//   int _currentPage = 0;
//
//   List<Widget> _buildPageIndicator() {
//     List<Widget> list = [];
//     for (int i = 0; i < _numPages; i++) {
//       list.add(i == _currentPage ? _indicator(true) : _indicator(false));
//     }
//     return list;
//   }
//
//   Widget _indicator(bool isActive) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 150),
//       margin: EdgeInsets.symmetric(horizontal: 8.0),
//       height: 8.0,
//       width: isActive ? 24.0 : 16.0,
//       decoration: BoxDecoration(
//         color: isActive ? Colors.white : CustomColors.webblenRed,
//         borderRadius: BorderRadius.all(Radius.circular(12)),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AnnotatedRegion<SystemUiOverlayStyle>(
//         value: SystemUiOverlayStyle.dark,
//         child: Container(
//           color: Colors.white,
//           child: Padding(
//             padding: EdgeInsets.symmetric(vertical: 20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 SizedBox(height: 100.0),
//                 Container(
//                   height: MediaQuery.of(context).size.height > 2000 ? MediaQuery.of(context).size.height * 0.8 : 500,
//                   child: PageView(
//                     physics: ClampingScrollPhysics(),
//                     controller: _pageController,
//                     onPageChanged: (int page) {
//                       setState(() {
//                         _currentPage = page;
//                       });
//                     },
//                     children: <Widget>[
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                         child: Column(
//                           children: <Widget>[
//                             Center(
//                               child: Image(
//                                 image: AssetImage(
//                                   'assets/images/modern_city.png',
//                                 ),
//                                 height: 300,
//                                 fit: BoxFit.contain,
//                                 filterQuality: FilterQuality.high,
//                               ),
//                             ),
//                             Text(
//                               'Welcome to Webblen',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
//                             ),
//                             SizedBox(height: 8.0),
//                             Text(
//                               'Get Paid to be Involved \n In Your Community',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                         child: Column(
//                           children: <Widget>[
//                             Center(
//                               child: Image(
//                                 image: AssetImage(
//                                   'assets/images/conversation.png',
//                                 ),
//                                 height: 300,
//                                 fit: BoxFit.contain,
//                                 filterQuality: FilterQuality.high,
//                               ),
//                             ),
//                             SizedBox(height: 30.0),
//                             Text(
//                               'Influence the Culture of Your Area',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
//                             ),
//                             SizedBox(height: 15.0),
//                             Text(
//                               "Share your events, ideas, and talents\ndirectly with the people around you",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.0),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Center(
//                               child: Image(
//                                 image: AssetImage(
//                                   'assets/images/phone_card.png',
//                                 ),
//                                 height: MediaQuery.of(context).size.width * 0.70,
//                                 width: MediaQuery.of(context).size.width * 0.70,
//                               ),
//                             ),
//                             SizedBox(height: 30.0),
//                             Text(
//                               'Buy and Sell Tickets \nLike Never Before',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
//                             ),
//                             SizedBox(height: 15.0),
//                             Text(
//                               "Sell tickets to live/digital events for free and easily manage the tickets you've purchased",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                         child: Column(
//                           children: <Widget>[
//                             Center(
//                               child: Image(
//                                 image: AssetImage(
//                                   'assets/images/onboarding3.png',
//                                 ),
//                                 height: MediaQuery.of(context).size.width * 0.7,
//                                 width: MediaQuery.of(context).size.width * 0.7,
//                               ),
//                             ),
//                             SizedBox(height: 30.0),
//                             Text(
//                               "It Pays to Be Involved",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
//                             ),
//                             SizedBox(height: 15.0),
//                             Text(
//                               "It doesn't just pay to be an event host or streamer. Webblen also pays you for attending events and checking into local streams!",
//                               style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.0),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             Center(
//                               child: Image(
//                                 image: AssetImage(
//                                   'assets/images/onboarding4.png',
//                                 ),
//                                 height: MediaQuery.of(context).size.width * 0.7,
//                                 width: MediaQuery.of(context).size.width * 0.7,
//                               ),
//                             ),
//                             SizedBox(height: 30.0),
//                             Text(
//                               'Join The Movement',
//                               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
//                             ),
//                             SizedBox(height: 15.0),
//                             Text(
//                               'Our mission is to create a world where it pays to be connected and involved with those around us. Join us and change the way you get invovled and build your community!',
//                               style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.0),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: _buildPageIndicator(),
//                 ),
//                 _currentPage != _numPages - 1
//                     ? Expanded(
//                         child: Align(
//                           alignment: FractionalOffset.bottomRight,
//                           child: FlatButton(
//                             onPressed: () {
//                               _pageController.nextPage(
//                                 duration: Duration(milliseconds: 500),
//                                 curve: Curves.ease,
//                               );
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               mainAxisSize: MainAxisSize.min,
//                               children: <Widget>[
//                                 Text(
//                                   'Next',
//                                   style: TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 20.0,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     : Text(''),
//               ],
//             ),
//           ),
//         ),
//       ),
//       bottomSheet: _currentPage == _numPages - 1
//           ? Container(
//               height: 100.0,
//               width: double.infinity,
//               color: Colors.white,
//               child: GestureDetector(
//                 onTap: () => PageTransitionService(context: context).transitionToLoginPage(),
//                 child: Center(
//                   child: Padding(
//                     padding: EdgeInsets.only(bottom: 30.0),
//                     child: Text(
//                       'Get started',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 20.0,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           : Text(''),
//     );
//   }
// }

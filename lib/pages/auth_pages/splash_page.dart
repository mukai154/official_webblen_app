import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/services_general/service_page_transitions.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final int _numPages = 5;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : CustomColors.webblenRed,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 32.0),
                Container(
                  height: 600.0,
                  child: PageView(
                    physics: ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/onboarding0.png',
                                ),
                                height: MediaQuery.of(context).size.width * 0.8,
                                width: MediaQuery.of(context).size.width * 0.8,
                              ),
                            ),
                            Text(
                              'Welcome to Webblen',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Get Paid to be Involved \nand Build Your Community',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/onboarding2.png',
                                ),
                                height: MediaQuery.of(context).size.width * 0.8,
                                width: MediaQuery.of(context).size.width * 0.8,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              'Stream to Everyone \nin Your Area',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              "Share your ideas and talent with a local audience. Or watch and support local streamers.",
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/onboarding1.png',
                                ),
                                height: MediaQuery.of(context).size.width * 0.8,
                                width: MediaQuery.of(context).size.width * 0.8,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              'Buy and Sell Tickets \nLike Never Before',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              "Sell tickets to live/digital events for free and easily manage the tickets you've purchased",
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/onboarding3.png',
                                ),
                                height: MediaQuery.of(context).size.width * 0.8,
                                width: MediaQuery.of(context).size.width * 0.8,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              "It Pays to Be Involved",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              "It doesn't just pay to be an event host or streamer. Webblen also pays you for attending events and checking into local streams!",
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/onboarding4.png',
                                ),
                                height: MediaQuery.of(context).size.width * 0.8,
                                width: MediaQuery.of(context).size.width * 0.8,
                              ),
                            ),
                            SizedBox(height: 30.0),
                            Text(
                              'Join The Movement',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30.0),
                            ),
                            SizedBox(height: 15.0),
                            Text(
                              'Our mission is to create a world where it pays to be connected and involved with those around us. Join us and change the way you get invovled and build your community!',
                              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                _currentPage != _numPages - 1
                    ? Expanded(
                        child: Align(
                          alignment: FractionalOffset.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Next',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Text(''),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _currentPage == _numPages - 1
          ? Container(
              height: 100.0,
              width: double.infinity,
              color: Colors.white,
              child: GestureDetector(
                onTap: () => PageTransitionService(context: context).transitionToLoginPage(),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30.0),
                    child: Text(
                      'Get started',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Text(''),
    );
  }
}
//class SplashPage extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: Container(
//        color: Colors.white,
//        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          crossAxisAlignment: CrossAxisAlignment.stretch,
//          children: [
//            Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                Column(
//                  children: <Widget>[
//                    MediaQuery(
//                      data: MediaQuery.of(context).copyWith(
//                        textScaleFactor: 1.0,
//                      ),
//                      child: CustomText(
//                        context: context,
//                        text: "Welcome to Webblen",
//                        textColor: Colors.black,
//                        textAlign: TextAlign.center,
//                        fontSize: 35.0,
//                        fontWeight: FontWeight.w700,
//                      ),
//                    ),
//                    MediaQuery(
//                      data: MediaQuery.of(context).copyWith(
//                        textScaleFactor: 1.0,
//                      ),
//                      child: CustomText(
//                        context: context,
//                        text: "Find Events. Build Communities. Get Paid.",
//                        textColor: Colors.black,
//                        textAlign: TextAlign.center,
//                        fontSize: 16.0,
//                        fontWeight: FontWeight.w300,
//                      ),
//                    ),
//                  ],
//                ),
//              ],
//            ),
//            SizedBox(height: 8.0),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                CustomColorButton(
//                  height: 45.0,
//                  width: 200.0,
//                  text: 'GET STARTED',
//                  backgroundColor: Colors.white,
//                  textColor: Colors.black,
//                  onPressed: () => PageTransitionService(context: context).transitionToLoginPage(),
//                ),
//              ],
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//}

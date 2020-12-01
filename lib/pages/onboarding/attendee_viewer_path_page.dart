import 'dart:ui';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:webblen/algolia/algolia_search.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/pages/onboarding/suggest_followers_page.dart';
import 'package:webblen/widgets/common/containers/text_field_container.dart';

class AttendeeViewerPathPage extends StatefulWidget {
  @override
  _AttendeeViewerPathPageState createState() => _AttendeeViewerPathPageState();
}

class _AttendeeViewerPathPageState extends State<AttendeeViewerPathPage> {
  bool isLoading = true;
  final introKey = GlobalKey<IntroductionScreenState>();
  bool showSkipButton = true;
  bool freezeSwipe = false;
  String uid;
  Map<dynamic, dynamic> allTags = {};
  String selectedCategory;
  List selectedTags = [];
  List<String> tagCategories = [];

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

  continuePath() {
    IntroductionScreenState screenState = introKey.currentState;
    screenState.next();
  }

  onboardCompleteTransition() {
    WebblenUserData().updateInterests(uid, selectedTags);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SuggestFollowersPage(
                  onboarding: true,
                )));
  }

  //Social Auth
  void linkFBAccount() async {
    setState(() {
      isLoading = true;
    });
    final LoginResult result = await FacebookAuth.instance.login(permissions: ['email']);
    switch (result.status) {
      case FacebookAuthLoginResponse.ok:
        BaseAuth().linkFacebookAccount(result).then((err) {
          if (err != null) {
            showAlertDialog(
              context: context,
              message: "This Account is Already In Associated with Another Account",
              barrierDismissible: true,
              actions: [
                AlertDialogAction(label: "Ok", isDefaultAction: true),
              ],
            );
          }
          setState(() {
            isLoading = false;
          });
        });
        break;
      case FacebookAuthLoginResponse.cancelled:
        showAlertDialog(
          context: context,
          message: "Cancelled Facebook Login",
          barrierDismissible: true,
          actions: [
            AlertDialogAction(label: "Ok", isDefaultAction: true),
          ],
        );
        setState(() {
          isLoading = false;
        });
        break;
      case FacebookAuthLoginResponse.error:
        showAlertDialog(
          context: context,
          message: "There was an Issue Signing Into Facebook",
          barrierDismissible: true,
          actions: [
            AlertDialogAction(label: "Ok", isDefaultAction: true),
          ],
        );
        setState(() {
          isLoading = false;
        });
        break;
    }
  }

  void linkYoutubeAccount() async {
    setState(() {
      isLoading = true;
    });
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
        'https://www.googleapis.com/auth/youtube',
        'https://www.googleapis.com/auth/youtube.readonly',
        'https://www.googleapis.com/auth/youtube.force-ssl',
        'https://www.googleapis.com/auth/youtube.upload',
      ],
    );
    GoogleSignInAccount googleAccount = await googleSignIn.signIn();
    if (googleAccount == null) {
      showAlertDialog(
        context: context,
        message: "Cancelled Google Login",
        barrierDismissible: true,
        actions: [
          AlertDialogAction(label: "Ok", isDefaultAction: true),
        ],
      );
      setState(() {
        isLoading = false;
      });
    }
    GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
    BaseAuth().linkYoutubeAccount(googleAuth).then((err) {
      if (err != null) {
        showAlertDialog(
          context: context,
          message: "This Account is Already In Associated with Another Account",
          barrierDismissible: true,
          actions: [
            AlertDialogAction(label: "Ok", isDefaultAction: true),
          ],
        );
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  ///PAGES
  //Even host
  PageViewModel initialAttendeeViewerPage(PageDecoration pageDecoration) {
    return PageViewModel(
      title: "Always Have Something to Do",
      body: "Webblen Helps You Find Posts, Events, Streams, and People in Your Area that Share Your Interests",
      image: onboardingImage('party'),
      decoration: pageDecoration,
    );
  }

  PageViewModel selectInterestsPage(PageDecoration pageDecoration) {
    return PageViewModel(
      titleWidget: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 80),
            Text(
              "What Are You Interested In?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            selectedCategory == null
                ? Container()
                : TextFieldContainer(
                    child: DropdownButton(
                        isExpanded: true,
                        underline: Container(),
                        value: selectedCategory,
                        items: tagCategories.map((String val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedCategory = val;
                          });
                        }),
                  ),
            SizedBox(height: 24),
            Divider(
              thickness: 0.5,
              indent: 16,
              endIndent: 16,
              color: Colors.black45,
            ),
            selectedCategory == null || selectedCategory == "Select Category"
                ? Container()
                : GridView.count(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    crossAxisCount: 3,
                    childAspectRatio: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: List.generate(allTags[selectedCategory].length - 1, (index) {
                      return GestureDetector(
                        onTap: () {
                          if (selectedTags.contains(allTags[selectedCategory][index])) {
                            selectedTags.remove(allTags[selectedCategory][index]);
                          } else {
                            selectedTags.add(allTags[selectedCategory][index]);
                          }
                          setState(() {});
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: selectedTags.contains(allTags[selectedCategory][index]) ? CustomColors.electronBlue : CustomColors.iosOffWhite,
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              allTags[selectedCategory][index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selectedTags.contains(allTags[selectedCategory][index]) ? Colors.white : Colors.black,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
          ],
        ),
      ),
      bodyWidget: Container(),
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
    AlgoliaSearch().getTagsAndCategories().then((res) {
      allTags = res;
      allTags.keys.forEach((key) {
        if (key != null) {
          tagCategories.add(key.toString());
        }
      });
      tagCategories.sort((a, b) => a.compareTo(b));
      tagCategories.insert(0, 'Select Category');
      selectedCategory = tagCategories.first;
      isLoading = false;
      setState(() {});
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
      onChange: (pageNum) {
        if (pageNum == 0) {
          showSkipButton = true;
        } else {
          showSkipButton = false;
        }
        setState(() {});
      },
      onDone: () => onboardCompleteTransition(),
      onSkip: () => Navigator.of(context).pop(),
      showSkipButton: showSkipButton,
      showNextButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: Text('Back', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      next: Icon(FontAwesomeIcons.arrowRight, size: 24.0, color: Colors.black),
      done: Text('Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
        initialAttendeeViewerPage(pageDecoration),
        selectInterestsPage(pageDecoration),
      ],
    );
  }
}

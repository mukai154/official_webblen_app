import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/state/progress_indicator.dart';
import 'package:webblen/widgets/widgets_user/user_details_profile_pic.dart';

class FollowSuggestionsPage extends StatefulWidget {
  @override
  _FollowSuggestionsPageState createState() => _FollowSuggestionsPageState();
}

class _FollowSuggestionsPageState extends State<FollowSuggestionsPage> {
  String uid;
  WebblenUser currentUser;
  List tags = [];
  List<WebblenUser> suggestedUsers = [];
  List newFollows = [];
  bool isLoading = true;
  bool hasLocation = false;
  String zipcode;

  transitionToUserPage(String val) async {
    ShowAlertDialogService().showLoadingDialog(context);
    WebblenUser user = await WebblenUserData().getUserByID(val);
    Navigator.of(context).pop();
    PageTransitionService(
      context: context,
      currentUser: currentUser,
      webblenUser: user,
    ).transitionToUserPage();
  }

  followUnfollowAction(String val) async {
    ShowAlertDialogService().showLoadingDialog(context);
    if (newFollows.contains(val)) {
      newFollows.remove(val);
    } else {
      newFollows.add(val);
    }
    setState(() {});
    await WebblenUserData().updateFollowingByID(currentUser.uid, val);
    Navigator.of(context).pop();
  }

  Future<Null> loadData() async {
    LocationData location = await LocationService().getCurrentLocation(context);
    if (location != null) {
      hasLocation = true;
      double lat = location.latitude;
      double lon = location.longitude;
      LocationService().getZipFromLatLon(lat, lon).then((res) {
        res = zipcode;
        WebblenUserData().getFollowerSuggestions(uid, zipcode, tags).then((res) {
          suggestedUsers = res;
          isLoading = false;
          setState(() {});
        });
      });
    } else {
      hasLocation = false;
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    BaseAuth().getCurrentUserID().then((res) {
      uid = res;
      setState(() {});
      WebblenUserData().getUserByID(uid).then((res) {
        currentUser = res;
        WebblenUserData().getInterests(uid).then((res) {
          tags = res;
          setState(() {});
          loadData();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar(
        "Follow Suggestions",
        context,
      ),
      body: isLoading
          ? CustomLinearProgress(progressBarColor: CustomColors.webblenRed)
          : Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              color: Colors.white,
              child: isLoading
                  ? Container()
                  : ListView.builder(
                      itemCount: suggestedUsers.length, //suggestedUsers.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => transitionToUserPage(suggestedUsers[index].uid),
                                child: Row(
                                  children: [
                                    UserDetailsProfilePic(
                                      size: 60,
                                      userPicUrl: suggestedUsers[index].profile_pic,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "@${suggestedUsers[index].username}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              newFollows.contains(suggestedUsers[index].uid)
                                  ? CustomColorButton(
                                      text: "Unfollow",
                                      textColor: CustomColors.lightAmericanGray,
                                      backgroundColor: Colors.white,
                                      height: 30.0,
                                      width: 100,
                                      onPressed: () => followUnfollowAction(suggestedUsers[index].uid),
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        FontAwesomeIcons.userPlus,
                                        size: 18.0,
                                        color: Colors.black,
                                      ),
                                      onPressed: () => followUnfollowAction(suggestedUsers[index].uid),
                                    ),
                            ],
                          ),
                        );
                      }),
            ),
    );
  }
}

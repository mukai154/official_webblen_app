import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/firebase_data/user_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';

class SetupPage extends StatefulWidget {
  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  File userImage;
  String uid;
  String username;

  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final usernameFormKey = GlobalKey<FormState>();
  final userSetupScaffoldKey = GlobalKey<ScaffoldState>();

  //Form Validations
  void submitUsernameAndImage() async {
    WebblenUser newUser = WebblenUser(
      blockedUsers: [],
      username: username.replaceAll(
        RegExp(r"\s+\b|\b\s"),
        "",
      ),
      uid: uid,
      profile_pic: "",
      eventHistory: [],
      eventPoints: 0.00,
      webblen: 0.001,
      impactPoints: 1.001,
      rewards: [],
      savedEvents: [],
      followers: [],
      following: [],
      lastCheckInTimeInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      achievements: [],
      notifyFlashEvents: true,
      notifyFriendRequests: true,
      notifyHotEvents: true,
      notifySuggestedEvents: true,
      notifyWalletDeposits: true,
      notifyNewMessages: true,
      lastNotifInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      messageNotificationCount: 0,
      friendRequestNotificationCount: 0,
      achievementNotificationCount: 0,
      eventNotificationCount: 0,
      walletNotificationCount: 0,
      isCommunityBuilder: false,
      isNewCommunityBuilder: false,
      communityBuilderNotificationCount: 0,
      notificationCount: 0,
      isOnWaitList: false,
      messageToken: '',
      isNew: true,
      canMakeAds: false,
      ap: 0.20,
      apLvl: 1,
      lastPayoutTimeInMilliseconds: DateTime.now().millisecondsSinceEpoch,
      eventsToLvlUp: 20,
    );

    createNewUser(
      userImage,
      newUser,
      uid,
    );
  }

  validateAndSubmit() async {
    bool usernameExists = false;
    final form = usernameFormKey.currentState;
    ScaffoldState scaffold = homeScaffoldKey.currentState;
    form.save();
    ShowAlertDialogService().showLoadingDialog(context);
    if (username.isEmpty) {
      Navigator.of(context).pop();
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            "Username Required",
          ),
          backgroundColor: Colors.red,
          duration: Duration(
            seconds: 3,
          ),
        ),
      );
    } else if (userImage == null) {
      Navigator.of(context).pop();
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            "Image Required",
          ),
          backgroundColor: Colors.red,
          duration: Duration(
            seconds: 3,
          ),
        ),
      );
    } else {
      username = username.toLowerCase().trim();
      usernameExists = await UserDataService().checkIfUsernameExists(username);
      if (usernameExists) {
        Navigator.of(context).pop();
        scaffold.showSnackBar(
          SnackBar(
            content: Text(
              "This Username is Already Taken",
            ),
            backgroundColor: Colors.red,
            duration: Duration(
              seconds: 3,
            ),
          ),
        );
      } else {
        submitUsernameAndImage();
      }
    }
  }

  createNewUser(File userImage, WebblenUser user, String uid) async {
    ScaffoldState scaffold = homeScaffoldKey.currentState;
    WebblenUserData()
        .createNewUser(
      userImage,
      user,
      uid,
    )
        .then((success) {
      if (success) {
        PageTransitionService(
          context: context,
        ).transitionToRootPage();
      } else {
        Navigator.of(context).pop();
        scaffold.showSnackBar(
          SnackBar(
            content: Text(
              "There was an unexpected error. Please Try Again Later.",
            ),
            backgroundColor: Colors.red,
            duration: Duration(
              seconds: 3,
            ),
          ),
        );
      }
    });
  }

  void setUserProfilePic(bool getImageFromCamera) async {
    Navigator.of(context).pop();
    setState(() {
      userImage = null;
    });
    userImage = getImageFromCamera
        ? await WebblenImagePicker(
            context: context,
            ratioX: 1.0,
            ratioY: 1.0,
          ).retrieveImageFromCamera()
        : await WebblenImagePicker(
            context: context,
            ratioX: 1.0,
            ratioY: 1.0,
          ).retrieveImageFromLibrary();
    if (userImage != null) {
      setState(() {});
    }
  }

  Widget _buildUsernameField() {
    return Theme(
      data: ThemeData(
        cursorColor: Colors.black,
      ),
      child: Container(
        height: 30.0,
        width: MediaQuery.of(context).size.width - 16,
        child: TextFormField(
          textCapitalization: TextCapitalization.none,
          initialValue: username,
          autocorrect: false,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 30.0,
            fontWeight: FontWeight.w700,
            fontFamily: "Nunito",
          ),
          autofocus: false,
          onSaved: (value) => username = value,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Username",
            hintStyle: TextStyle(
              color: Colors.black54,
            ),
          ),
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
    final addImageButton = Material(
      borderRadius: BorderRadius.circular(25.0),
      elevation: 0.0,
      color: Colors.transparent,
      child: InkWell(
        onTap: () => ShowAlertDialogService().showImageSelectDialog(
          context,
          () => setUserProfilePic(true),
          () => setUserProfilePic(false),
        ),
        borderRadius: BorderRadius.circular(80.0),
        child: userImage == null
            ? Icon(
                Icons.camera_alt,
                size: 40.0,
                color: FlatColors.darkGray,
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100.0),
                  boxShadow: ([
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2.0,
                      spreadRadius: 2.0,
                      offset: Offset(
                        0.0,
                        5.0,
                      ),
                    ),
                  ]),
                ),
                child: CircleAvatar(
                  backgroundImage: FileImage(userImage),
                  radius: 80.0,
                ),
              ),
      ),
    );

    final namePicPage = Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Form(
          key: usernameFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Fonts().textW600(
                        "Welcome to Webblen!",
                        24.0,
                        Colors.black,
                        TextAlign.center,
                      ),
                      SizedBox(height: 8.0),
                      Fonts().textW400(
                        "Let's Get You Started",
                        16.0,
                        Colors.black,
                        TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      addImageButton,
                      SizedBox(
                        height: 35.0,
                      ),
                      _buildUsernameField(),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CustomColorButton(
                    text: "Submit",
                    textColor: FlatColors.darkGray,
                    backgroundColor: Colors.white,
                    width: 200.0,
                    height: 45.0,
                    onPressed: () => validateAndSubmit(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return new Scaffold(
      key: homeScaffoldKey,
      body: namePicPage,
    );
  }
}

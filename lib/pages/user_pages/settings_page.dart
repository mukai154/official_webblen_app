import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/stripe/stripe_payment.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/state/progress_indicator.dart';
import 'package:webblen/widgets/widgets_icons/icon_bubble.dart';
import 'package:webblen/widgets/widgets_user/user_details_profile_pic.dart';

class SettingsPage extends StatefulWidget {
  final WebblenUser currentUser;

  SettingsPage({
    this.currentUser,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> settingsFormKey = GlobalKey<FormState>();
  bool isLoading = true;
  File newUserImage;
  String stripeConnectURL;
  bool stripeAccountIsSetup = false;

  Widget optionRow(Icon icon, String optionName, Color optionColor, VoidCallback onTap) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        height: 35.0,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                left: 8.0,
                right: 16.0,
                top: 4.0,
                bottom: 4.0,
              ),
              child: icon,
            ),
            MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0,
              ),
              child: Fonts().textW400(
                optionName,
                16.0,
                optionColor,
                TextAlign.left,
              ),
            ),
          ],
        ),
      ),
      onTap: onTap,
    );
  }

  Future<Null> updateUserPic(File userImage, String uid) async {
    ShowAlertDialogService().showLoadingDialog(context);
    Reference storageReference = FirebaseStorage.instance.ref();
    String fileName = "$uid.jpg";
    storageReference.child("profile_pics").child(fileName).putFile(userImage);
    String downloadUrl = await uploadUserImage(
      userImage,
      fileName,
    );
    WebblenUserData()
        .updateUserProfilePic(
      widget.currentUser.uid,
      downloadUrl,
    )
        .then((e) {
      if (e != null) {
        Navigator.of(context).pop();
        ShowAlertDialogService().showFailureDialog(context, "Error", "There was an issue uploading a new pic");
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  Future<String> uploadUserImage(File userImage, String fileName) async {
    setState(() {});
    Reference ref = FirebaseStorage.instance.ref().child("profile_pics").child(fileName);
    UploadTask uploadTask = ref.putFile(userImage);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }

  void changeUserProfilePic(bool getImageFromCamera) async {
    Navigator.of(context).pop();
    setState(() {
      newUserImage = null;
    });
    newUserImage = getImageFromCamera
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
    if (newUserImage != null) {
      await updateUserPic(
        newUserImage,
        widget.currentUser.uid,
      );
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    stripeConnectURL = "https://us-central1-webblen-events.cloudfunctions.net/connectStripeCustomAccount?uid=${widget.currentUser.uid}";
    StripePaymentService().getStripeUID(widget.currentUser.uid).then((res) {
      if (res != null) {
        stripeAccountIsSetup = true;
      }
      isLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar(
        "Settings",
        context,
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            isLoading
                ? CustomLinearProgress(progressBarColor: CustomColors.webblenRed)
                : Form(
                    key: settingsFormKey,
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance.collection("webblen_user").doc(widget.currentUser.uid).snapshots(),
                      builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                        if (!userSnapshot.hasData)
                          return Text(
                            "Loading...",
                          );
                        var userData = userSnapshot.data.data();
                        return Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 16.0,
                                    bottom: 4.0,
                                  ),
                                  child: Stack(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () => ShowAlertDialogService().showImageSelectDialog(
                                          context,
                                          () => changeUserProfilePic(true),
                                          () => changeUserProfilePic(false),
                                        ),
                                        child: newUserImage == null
                                            ? UserDetailsProfilePic(
                                                userPicUrl: userData['d']['profile_pic'],
                                                size: 100.0,
                                              )
                                            : CircleAvatar(
                                                backgroundImage: FileImage(newUserImage),
                                                radius: 50.0,
                                              ),
                                      ),
                                      Positioned(
                                        right: 0.0,
                                        top: 0.0,
                                        child: IconBubble(
                                          icon: Icon(
                                            Icons.camera_alt,
                                            color: Colors.black,
                                            size: 16.0,
                                          ),
                                          color: CustomColors.clouds,
                                          size: 30.0,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: 24.0,
                              ),
                              child: Fonts().textW700(
                                "@${widget.currentUser.username}",
                                24.0,
                                Colors.black,
                                TextAlign.left,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Fonts().textW500(
                                    "Notification Preferences",
                                    14.0,
                                    Colors.black,
                                    TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 32.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Fonts().textW700(
                                    "Wallet Deposits",
                                    18.0,
                                    Colors.black,
                                    TextAlign.left,
                                  ),
                                  Switch(
                                    value: userData['notifyDeposits'] == null ? true : userData['notifyDeposits'],
                                    onChanged: (val) => WebblenUserData().updateNotificationPermission(
                                      widget.currentUser.uid,
                                      "notifyDeposits",
                                      val,
                                    ),
                                    activeColor: CustomColors.webblenRed,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 32.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Fonts().textW700(
                                    "New Followers",
                                    18.0,
                                    Colors.black,
                                    TextAlign.left,
                                  ),
                                  Switch(
                                    value: userData['notifyNewFollowers'] == null ? true : userData['notifyNewFollowers'],
                                    onChanged: (val) => WebblenUserData().updateNotificationPermission(
                                      widget.currentUser.uid,
                                      "notifyNewFollowers",
                                      val,
                                    ),
                                    activeColor: CustomColors.webblenRed,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 32.0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Fonts().textW700(
                                    "Nearby Events & Streams",
                                    18.0,
                                    Colors.black,
                                    TextAlign.left,
                                  ),
                                  Switch(
                                    value: true, //widget.currentUser.notifyNewMessages,
                                    onChanged: (val) => WebblenUserData().updateNotificationPermission(
                                      widget.currentUser.uid,
                                      "notifyNearbyEvents",
                                      val,
                                    ),
                                    activeColor: CustomColors.webblenRed,
                                  ),
                                ],
                              ),
                            ),

//                  optionRow(
//                    Icon(
//                      FontAwesomeIcons.comments,
//                      color: FlatColors.blackPearl,
//                      size: 18.0,
//                    ),
//                    'Invite Friends',
//                    FlatColors.blackPearl,
//                    () async {
//                      Contact contact = await _contactPicker.selectContact();
//                      SendInviteMessage().sendSMS(
//                        'test message',
//                        [contact.phoneNumber.number],
//                      );
//                    },
//                  ),
                            StreamBuilder(
                              stream: FirebaseFirestore.instance.collection("stripe").doc(widget.currentUser.uid).snapshots(),
                              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                if (!snapshot.hasData) return Container();
                                var stripeAccountExists = snapshot.data.exists;
                                return !stripeAccountExists
                                    ? Container(
                                        child: Column(
                                          children: [
                                            SizedBox(height: 16.0),
                                            Container(
                                              color: Colors.black12,
                                              height: 0.5,
                                            ),
                                            SizedBox(height: 8.0),
                                            optionRow(
                                              Icon(FontAwesomeIcons.briefcase, color: CustomColors.blackPearl, size: 18.0),
                                              'Create Earnings Account',
                                              CustomColors.blackPearl,
                                              () => OpenUrl().launchInWebViewOrVC(context, stripeConnectURL),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container();
                              },
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              color: Colors.black12,
                              height: 0.5,
                            ),
                            SizedBox(height: 8.0),
                            optionRow(
                              Icon(FontAwesomeIcons.heart, color: CustomColors.blackPearl, size: 18.0),
                              'My Interests',
                              CustomColors.blackPearl,
                              () => PageTransitionService(context: context).transitionToInterestsPage(),
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              color: Colors.black12,
                              height: 0.5,
                            ),
                            SizedBox(height: 8.0),
                            optionRow(
                              Icon(FontAwesomeIcons.questionCircle, color: CustomColors.blackPearl, size: 18.0),
                              'Help/FAQ',
                              CustomColors.blackPearl,
                              () => OpenUrl().launchInWebViewOrVC(context, 'https://www.webblen.io/faq'),
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              color: Colors.black12,
                              height: 0.5,
                            ),
                            SizedBox(height: 8.0),
                            optionRow(
                              Icon(
                                FontAwesomeIcons.signOutAlt,
                                color: CustomColors.blackPearl,
                                size: 18.0,
                              ),
                              'logout',
                              CustomColors.blackPearl,
                              () => ShowAlertDialogService().showLogoutDialog(context),
                            ),
                            SizedBox(height: 8.0),
                            Container(
                              color: Colors.black12,
                              height: 0.5,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

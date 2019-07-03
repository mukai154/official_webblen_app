import 'package:flutter/material.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:webblen/widgets_common/common_flushbar.dart';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/widgets_user/user_details_profile_pic.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/firebase_services/user_data.dart';
import 'package:webblen/firebase_services/community_data.dart';

class SettingsPage extends StatefulWidget {

  final WebblenUser currentUser;
  SettingsPage({this.currentUser});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  final GlobalKey<FormState> settingsFormKey = GlobalKey<FormState>();
  bool isLoading = false;
  File newUserImage;

  Future<Null> updateUserPic(File userImage, String uid) async {
    ShowAlertDialogService().showLoadingDialog(context);
    StorageReference storageReference = FirebaseStorage.instance.ref();
    String fileName = "$uid.jpg";
    storageReference.child("profile_pics").child(fileName).putFile(userImage);
    String downloadUrl = await uploadUserImage(userImage, fileName);
    Firestore.instance.collection("users").document(uid).updateData({"profile_pic": downloadUrl}).whenComplete(() {
      Navigator.of(context).pop();
    }).catchError((e) {
      Navigator.of(context).pop();
      AlertFlushbar(headerText: "Submit Error", bodyText: e.details)
          .showAlertFlushbar(context);
    });
  }

  Future<String> uploadUserImage(File userImage, String fileName) async {
    setState(() {});
    StorageReference storageReference = FirebaseStorage.instance.ref();
    StorageReference ref = storageReference.child("profile_pics").child(fileName);
    StorageUploadTask uploadTask = ref.putFile(userImage);
    String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL() as String;
    return downloadUrl;
  }

  void changeUserProfilePic(bool getImageFromCamera) async {
    setState(() {
      newUserImage = null;
    });
    newUserImage = getImageFromCamera
        ? await WebblenImagePicker(context: context, ratioX: 9.0, ratioY: 7.0).retrieveImageFromCamera()
        : await WebblenImagePicker(context: context, ratioX: 9.0, ratioY: 7.0).retrieveImageFromLibrary();
    if (newUserImage != null){
      await updateUserPic(newUserImage, widget.currentUser.uid);
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    UserDataService().addUserDataField("canMakeAds", false);
//    UserDataService().reinstateUserPics();
    //CommunityDataService().updateCommunityDataFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().basicAppBar("Settings"),
        body: ListView(
          children: <Widget>[
            Form(
              key: settingsFormKey,
              child: Column(
                children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(top: 16.0, bottom: 4.0),
                            child: InkWell(
                              onTap: () => ShowAlertDialogService().showImageSelectDialog(context, () => changeUserProfilePic(true), () => changeUserProfilePic(false)),
                              child: newUserImage == null
                                  ? UserDetailsProfilePic(userPicUrl: widget.currentUser.profile_pic, size: 100.0)
                                  : CircleAvatar(backgroundImage: FileImage(newUserImage), radius: 50.0,) ,
                            )
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 24.0),
                      child: Fonts().textW700("@${widget.currentUser.username}", 24.0, FlatColors.darkGray, TextAlign.left),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16.0, right: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Fonts().textW500("Notification Preferences", 14.0, Colors.black38, TextAlign.center),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Fonts().textW700("Wallet Deposits", 18.0, FlatColors.darkGray, TextAlign.left),
                          Switch(
                            value: widget.currentUser.notifyWalletDeposits,
                            onChanged: (val) => UserDataService().updateNotificationPermission(widget.currentUser.uid, "notifyWalletDeposits", val),
                            activeColor: FlatColors.webblenRed,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Fonts().textW700("Friend Requests", 18.0, FlatColors.darkGray, TextAlign.left),
                          Switch(
                            value: widget.currentUser.notifyFriendRequests,
                            onChanged: (val) => UserDataService().updateNotificationPermission(widget.currentUser.uid, "notifyFriendRequests", val),
                            activeColor: FlatColors.webblenRed,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Fonts().textW700("New Messages", 18.0, FlatColors.darkGray, TextAlign.left),
                          Switch(
                            value: widget.currentUser.notifyNewMessages,
                            onChanged: (val) => UserDataService().updateNotificationPermission(widget.currentUser.uid, "notifyNewMessages", val),
                            activeColor: FlatColors.webblenRed,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Fonts().textW700("Flash Events", 18.0, FlatColors.darkGray, TextAlign.left),
                          Switch(
                            value: widget.currentUser.notifyFlashEvents,
                            onChanged: (val) => UserDataService().updateNotificationPermission(widget.currentUser.uid, "notifyFlashEvents", val),
                            activeColor: FlatColors.webblenRed,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Fonts().textW700("Suggested Events", 18.0, FlatColors.darkGray, TextAlign.left),
                          Switch(
                            value: widget.currentUser.notifySuggestedEvents,
                            onChanged: (val) => UserDataService().updateNotificationPermission(widget.currentUser.uid, "notifySuggestedEvents", val),
                            activeColor: FlatColors.webblenRed,
                          ),
                        ],
                      ),
                    ),
                  ],
              ),
            ),
          ],
        )
    );
  }


}

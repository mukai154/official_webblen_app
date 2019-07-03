import 'package:flutter/material.dart';
import 'package:webblen/firebase_services/auth.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/firebase_services/user_data.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';
import 'package:webblen/widgets_common/common_flushbar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';

class SetupPage extends StatefulWidget {
  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  File userImage;
  String uid;
  String username;
  bool isLoading = true;


  final homeScaffoldKey = new GlobalKey<ScaffoldState>();
  final usernameFormKey = new GlobalKey<FormState>();
  final userSetupScaffoldKey = new GlobalKey<ScaffoldState>();

  //Form Validations
  void submitUsernameAndImage() async {
    setState(() {
      isLoading = true;
    });

    WebblenUser newUser = WebblenUser(
      blockedUsers: [],
      username: username.replaceAll(new RegExp(r"\s+\b|\b\s"), ""),
      uid: uid,
      profile_pic: "",
      eventHistory: [],
      eventPoints: 0.00,
      impactPoints: 1.00,
      rewards: [],
      savedEvents: [],
      friends: [],
      userLat: null,
      userLon: null,
      lastCheckIn: null,
      achievements: [],
      notifyFlashEvents: true,
      notifyFriendRequests: true,
      notifyHotEvents: true,
      notifySuggestedEvents: true,
      notifyWalletDeposits: true,
      notifyNewMessages: true,
      lastNotificationSentAt: DateTime.now().millisecondsSinceEpoch.toString(),
      messageNotificationCount: 0,
      friendRequestNotificationCount: 0,
      achievementNotificationCount: 0,
      eventNotificationCount: 0,
      walletNotificationCount: 0,
      isCommunityBuilder: false,
      isNewCommunityBuilder: false,
      communityBuilderNotificationCount: 0,
      notificationCount: 0,
      friendRequests: [],
      isOnWaitList: false,
      messageToken: '',
      isNew: true,
      location: {},
      communities: {},
      followingCommunities: {},
      canMakeAds: false
    );

    createNewUser(userImage, newUser, uid).then((error) {
      if (error.isEmpty){
        PageTransitionService(context: context).transitionToRootPage();
      }
    });
  }

  validateAndSubmit() async {
    final form = usernameFormKey.currentState;
    form.save();
    ShowAlertDialogService().showLoadingDialog(context);
    if (username.isEmpty) {
      Navigator.of(context).pop();
      AlertFlushbar(headerText: "Username Error", bodyText: "Username Required").showAlertFlushbar(context);
    } else if (userImage == null) {
      Navigator.of(context).pop();
      AlertFlushbar(headerText: "Image Error", bodyText: "Image Required").showAlertFlushbar(context);
    } else {
      username = username.toLowerCase().trim();
      await UserDataService().checkIfUserExists(username.replaceAll(new RegExp(r"\s+\b|\b\s"), "")).then((exists){
        if (exists){
          Navigator.of(context).pop();
          AlertFlushbar(headerText: "Username Error", bodyText: "Username Already Taken").showAlertFlushbar(context);
        } else {
          submitUsernameAndImage();
        }
      });

    }
  }

  Future<String> createNewUser(File userImage, WebblenUser user, String uid) async {
    String error = "";
    ShowAlertDialogService().showLoadingDialog(context);
    StorageReference storageReference = FirebaseStorage.instance.ref();
    String fileName = "$uid.jpg";
    storageReference.child("profile_pics").child(fileName).putFile(userImage);
    String downloadUrl = await uploadUserImage(userImage, fileName);

    user.profile_pic = downloadUrl.toString();

    Firestore.instance.collection("users").document(uid).setData(user.toMap()).whenComplete(() {
    }).catchError((e) {
      Navigator.of(context).pop();
      AlertFlushbar(headerText: "Submit Error", bodyText: e.details)
          .showAlertFlushbar(context);
    });
    return error;
  }

  Future<String> uploadUserImage(File userImage, String fileName) async {
    StorageReference storageReference = FirebaseStorage.instance.ref();
    StorageReference ref = storageReference.child("profile_pics").child(fileName);
    StorageUploadTask uploadTask = ref.putFile(userImage);
    String downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL() as String;
    return downloadUrl;
  }


  void setUserProfilePic(bool getImageFromCamera) async {
    setState(() {
      userImage = null;
    });
    userImage = getImageFromCamera
        ? await WebblenImagePicker(context: context, ratioX: 9.0, ratioY: 7.0).retrieveImageFromCamera()
        : await WebblenImagePicker(context: context, ratioX: 9.0, ratioY: 7.0).retrieveImageFromLibrary();
    if (userImage != null){
      setState(() {});
    }
  }

  Widget _buildUsernameField() {
    return Theme(
      data: ThemeData(
        cursorColor: Colors.white
      ),
      child:  Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        child: new TextFormField(
          textCapitalization: TextCapitalization.none,
          initialValue: username,
          textAlign: TextAlign.center,
          style: new TextStyle(color: FlatColors.darkGray, fontSize: 30.0, fontWeight: FontWeight.w700, fontFamily: "Nunito"),
          autofocus: false,
          onSaved: (value) => username = value,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Username",
            hintStyle: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    BaseAuth().currentUser().then((userID) {
      setState(() {
        uid = userID;
        isLoading = false;
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
          onTap: () => ShowAlertDialogService().showImageSelectDialog(context, () => setUserProfilePic(true), () => setUserProfilePic(false)),
          borderRadius: BorderRadius.circular(80.0),
          child: userImage == null
              ? new Icon(Icons.camera_alt, size: 40.0, color: FlatColors.darkGray,)
              : new Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100.0),
                boxShadow: ([
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2.0,
                    spreadRadius: 2.0,
                    offset: Offset(0.0, 5.0),
                  ),
                ])),
            child: CircleAvatar(
              backgroundImage: FileImage(userImage),
              radius: 80.0,
            ),
          )
      ),
    );


    final namePicPage = Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: Form(
              key: usernameFormKey,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  addImageButton,
                  SizedBox(height: 35.0),
                  _buildUsernameField(),
                  SizedBox(height: 35.0),
                  CustomColorButton(
                    text: "Submit",
                    textColor: FlatColors.darkGray,
                    backgroundColor: Colors.white,
                    width: 150.0,
                    height: 45.0,
                    onPressed: () => validateAndSubmit(),
                  )
                ],
              ),
            ),

      ),
    );

    return new Scaffold(
      key: homeScaffoldKey,
      body: namePicPage
    );
  }
}
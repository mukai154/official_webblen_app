import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:social_share_plugin/social_share_plugin.dart';
import 'package:webblen/algolia/algolia_search.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/constants/strings.dart';
import 'package:webblen/firebase/data/post_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/firebase/services/dynamic_links.dart';
import 'package:webblen/models/webblen_post.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:webblen/widgets/common/alerts/custom_alerts.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/containers/round_container.dart';
import 'package:webblen/widgets/common/containers/tag_container.dart';
import 'package:webblen/widgets/common/containers/text_field_container.dart';
import 'package:webblen/widgets/common/state/progress_indicator.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';

class CreatePostPage extends StatefulWidget {
  final String postID;
  CreatePostPage({this.postID});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  String currentUID;
  WebblenUser currentUser;
  bool isLoading = true;
  bool isTypingMultiLine = false;
  ScrollController scrollController = ScrollController();
  TextEditingController messageTextController = TextEditingController();
  TextEditingController tagTextController = TextEditingController();
  GlobalKey formKey = GlobalKey<FormState>();

  //Post Details
  WebblenPost post;
  String body;
  String imgURL;
  //Location Details
  double lat;
  double lon;
  String postAddress;
  String city;
  String province = "AL";
  String zipPostalCode;
  List nearbyZipcodes = [];
  List sharedComs = [];
  List tags = [];
  List originallySavedBy = [];
  List participantIDs = [];
  bool paidOut = false;
  bool reported = false;
  int originalPostTimeInMilliseconds;
  int commentCount = 0;

  // Event Image
  File imgFile;

  //Additional Info & Social Links
  String postCategory = 'Select Category';

  copyNewPostLink() async {
    ShowAlertDialogService().showLoadingInfoDialog(context, "Generating Link...");
    String url = await DynamicLinks().createDynamicLink(
      linkType: "post",
      id: post.id,
      title: "Checkout My New Post on Webblen",
      description: post.body.length > 50 ? post.body.substring(0, 49) + "..." : post.body,
      imageURL: post.imageURL == null
          ? "https://firebasestorage.googleapis.com/v0/b/webblen-events.appspot.com/o/profile_pics%2FEtKiw3gK37QsOg6tPBnSJ8MhCm23.png?alt=media&token=6076da1d-ef93-4d3c-9937-a67dda7094ad"
          : post.imageURL,
    );
    Clipboard.setData(ClipboardData(text: url));
    Navigator.of(context).pop();
    ShowAlertDialogService().showSuccessDialog(context, "Link Copied!", "Feel Free to Share it");
  }

  shareToInstagram() async {
    PermissionStatus status = await Permission.photos.status;
    if (status.isUndetermined) {
      status = await Permission.photos.request();
    }
    if (status.isGranted) {
      ShowAlertDialogService().showLoadingInfoDialog(context, "Exporting to Instagram...");
      Directory dir = await getApplicationDocumentsDirectory();
      String path = dir.path;
      File file = await imgFile.copy('$path/webblen${DateTime.now().millisecondsSinceEpoch.toString()}.png');
      Navigator.of(context).pop();
      SocialSharePlugin.shareToFeedInstagram(path: file.path);
    }
  }

  //Other
  void dismissKeyboard() {
    FocusScope.of(context).unfocus();
    isTypingMultiLine = false;
    setState(() {});
  }

  GoogleMapsPlaces _places = GoogleMapsPlaces(
    apiKey: Strings.googleAPIKEY,
    //baseUrl: Strings.proxyMapsURL,
  );

  openGoogleAutoComplete() async {
    Prediction p = await PlacesAutocomplete.show(
      context: context,
      apiKey: Strings.googleAPIKEY,
      onError: (res) {
        print(res.errorMessage);
      },
      //proxyBaseUrl: Strings.proxyMapsURL,
      mode: Mode.overlay,
      language: "en",
      components: [
        Component(
          Component.country,
          "us",
        ),
      ],
    );
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    postAddress = detail.result.formattedAddress;
    lat = detail.result.geometry.location.lat;
    lon = detail.result.geometry.location.lng;
    CustomAlerts().showLoadingAlert(context, "Setting Location...");
    Map<dynamic, dynamic> locationData = await LocationService().reverseGeocodeLatLon(lat, lon);
    Navigator.of(context).pop();
    zipPostalCode = locationData['zipcode'];
    city = locationData['city'];
    province = locationData['administrativeLevels']['level1short'];
    lat = detail.result.geometry.location.lat;
    lon = detail.result.geometry.location.lng;
    setState(() {});
  }

  Widget addImageButton() {
    return GestureDetector(
      onTap: () async {
        dismissKeyboard();
        String res = await showModalActionSheet(
          context: context,
          // title: "Add Image",
          message: "Add Image",
          actions: [
            SheetAction(label: "Camera", key: 'camera', icon: Icons.camera_alt),
            SheetAction(label: "Gallery", key: 'gallery', icon: Icons.image),
          ],
        );
        if (res == "camera") {
          setPostImage(true);
        } else if (res == "gallery") {
          setPostImage(false);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.black12,
        ),
        child: widget.postID != null && imgURL != null
            ? imgFile == null
                ? CachedNetworkImage(
                    imageUrl: imgURL,
                    fit: BoxFit.contain,
                  )
                : Image.file(
                    imgFile,
                    fit: BoxFit.contain,
                  )
            : imgFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.camera_alt,
                        size: 40.0,
                        color: CustomColors.londonSquare,
                      ),
                      Text(
                        "1:1",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: CustomColors.londonSquare, fontSize: 16.0, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        "(Optional)",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: CustomColors.londonSquare, fontSize: 16.0, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                : Image.file(
                    imgFile,
                    fit: BoxFit.contain,
                  ),
      ),
    );
  }

  Widget sectionHeader(String sectionNumber, String header) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black26,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomColors.webblenRed, CustomColors.webblenPink],
              ),
            ),
            child: Center(
              child: CustomText(
                context: context,
                text: sectionNumber,
                textColor: Colors.white,
                textAlign: TextAlign.left,
                fontSize: 24.0,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(width: 8.0),
          CustomText(
            context: context,
            text: header,
            textColor: Colors.black,
            textAlign: TextAlign.left,
            fontSize: 24.0,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }

  Widget fieldHeader(String header, bool isRequired) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: <Widget>[
          CustomText(
            context: context,
            text: header,
            textColor: Colors.black,
            textAlign: TextAlign.left,
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
          isRequired
              ? CustomText(
                  context: context,
                  text: " *",
                  textColor: Colors.red,
                  textAlign: TextAlign.left,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                )
              : Container(),
        ],
      ),
    );
  }

  Widget postLocationField() {
    return GestureDetector(
      onTap: () => openGoogleAutoComplete(),
      child: TextFieldContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 40.0,
              padding: EdgeInsets.only(top: 10.0),
              child: CustomText(
                context: context,
                text: postAddress == null || postAddress.isEmpty ? "Search for Address" : postAddress,
                textColor: postAddress == null || postAddress.isEmpty ? Colors.black54 : Colors.black,
                textAlign: TextAlign.left,
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setPostImage(bool getImageFromCamera) async {
    setState(() {
      imgFile = null;
    });
    imgFile = getImageFromCamera
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
    if (imgFile != null) {
      setState(() {});
    }
  }

  Widget postBodyField() {
    return TextFieldContainer(
      child: TextFormField(
        onTap: () {
          isTypingMultiLine = true;
          setState(() {});
        },
        initialValue: body,
        cursorColor: Colors.black,
        validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
        maxLines: 5,
        maxLength: 500,
        onChanged: (value) {
          setState(() {
            body = value.trim();
          });
        },
        decoration: InputDecoration(
          hintText: "What's on Your Mind?",
          border: InputBorder.none,
        ),
      ),
    );
  }

  //CREATE EVENT
  submitPost() async {
    CustomAlerts().showLoadingAlert(context, "Uploading Post...");
    WebblenPost newPost = WebblenPost(
      id: widget.postID == null ? null : widget.postID,
      postType: "post",
      parentID: null,
      authorID: currentUser.uid,
      imageURL: imgURL == null ? null : imgURL,
      body: body.trim(),
      nearbyZipcodes: [],
      commentCount: commentCount,
      postDateTimeInMilliseconds: originalPostTimeInMilliseconds == null ? DateTime.now().millisecondsSinceEpoch : originalPostTimeInMilliseconds,
      reported: reported,
      savedBy: originallySavedBy,
      sharedComs: sharedComs,
      tags: tags,
      paidOut: paidOut,
      participantIDs: participantIDs,
      followers: currentUser.followers,
    );
    PostDataService().uploadPost(newPost, zipPostalCode, imgFile).then((res) {
      if (res != null) {
        post = res;
        setState(() {});
        Navigator.of(context).pop();
        showModalBottomSheet(
          context: context,
          isDismissible: false,
          backgroundColor: Colors.white,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  height: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'Post Successful!',
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Share It with the Rest of the World?",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => copyNewPostLink(),
                            child: Container(
                              child: Column(
                                children: [
                                  RoundContainer(
                                    size: 32,
                                    color: CustomColors.darkMountainGreen,
                                    child: Icon(
                                      FontAwesomeIcons.link,
                                      color: Colors.white,
                                      size: 16.0,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Copy Link',
                                    style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          imgFile == null
                              ? Container()
                              : GestureDetector(
                                  onTap: () => shareToInstagram(),
                                  child: Container(
                                    child: Column(
                                      children: [
                                        RoundContainer(
                                          size: 32,
                                          color: CustomColors.webblenPink,
                                          child: Icon(
                                            FontAwesomeIcons.instagram,
                                            color: Colors.white,
                                            size: 16.0,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Facebook',
                                          style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            child: Text(
                              'Done',
                              style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w700),
                            ),
                            onTap: () => PageTransitionService(context: context).returnToRootPage(),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      } else {
        Navigator.of(context).pop();
        showOkAlertDialog(
          context: context,
          message: "There was an issue uploading your post. Please try again.",
          okLabel: "Ok",
          barrierDismissible: true,
        );
      }
    });
  }

  validateAndSubmitPost() {
    FormState formState = formKey.currentState;
    formState.save();
    if (body == null || body.isEmpty) {
      showOkAlertDialog(
        context: context,
        message: "Post Message Missing",
        okLabel: "Ok",
        barrierDismissible: true,
      );
    } else if (postAddress == null || postAddress.isEmpty) {
      showOkAlertDialog(
        context: context,
        message: "Post Location Missing",
        okLabel: "Ok",
        barrierDismissible: true,
      );
    } else if (nearbyZipcodes.isEmpty && zipPostalCode.length != 5) {
      showOkAlertDialog(
        context: context,
        message: "Please Define a Better Location for this Post",
        okLabel: "Ok",
        barrierDismissible: true,
      );
    } else {
      submitPost();
    }
  }

  @override
  void initState() {
    super.initState();
    BaseAuth().getCurrentUserID().then((res) {
      if (res != null) {
        setState(() {
          currentUID = res;
        });
        WebblenUserData().getUserByID(currentUID).then((res) {
          currentUser = res;
          print(currentUser.followers);
          setState(() {});
        });
      }
      if (widget.postID != null) {
        PostDataService().getPost(widget.postID).then((res) {
          print(res.tags);
          if (res != null) {
            body = res.body;
            imgURL = res.imageURL == null ? null : res.imageURL;
            zipPostalCode = res.nearbyZipcodes.first;
            originalPostTimeInMilliseconds = res.postDateTimeInMilliseconds;
            tags = res.tags;
            sharedComs = res.sharedComs;
            originallySavedBy = res.savedBy;
            commentCount = res.commentCount;
            participantIDs = res.participantIDs;
            paidOut = res.paidOut;
            reported = res.reported;
          }
          isLoading = false;
          setState(() {});
        });
      } else {
        isLoading = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().newEventAppBar(
          context, widget.postID != null ? 'Editing Post' : 'New Post', widget.postID != null ? 'Cancel Editing Post?' : 'Cancel Adding New Post?', () {
        Navigator.of(context).pop();
      },
          isTypingMultiLine
              ? GestureDetector(
                  onTap: () => dismissKeyboard(),
                  child: Container(
                    margin: EdgeInsets.only(right: 16.0, top: 16.0),
                    child: CustomText(
                      context: context,
                      text: "Dismiss",
                      textColor: Colors.blueAccent,
                      textAlign: TextAlign.left,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ))
              : Container()),
      body: Container(
        child: Form(
          key: formKey,
          child: ListView(
            controller: scrollController,
            shrinkWrap: true,
            children: <Widget>[
              isLoading
                  ? Container(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Column(
                        children: <Widget>[
                          CustomLinearProgress(progressBarColor: CustomColors.webblenRed),
                        ],
                      ),
                    )
                  : Container(
                      child: Column(
                        children: <Widget>[
                          addImageButton(),
                          Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: tags.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      tags.removeAt(index);
                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 8.0, top: 16.0),
                                      child: TagContainer(
                                        tag: tags[index],
                                        width: 100,
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          SizedBox(height: 16.0),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                TextFieldContainer(
                                  height: 50,
                                  child: TypeAheadField(
                                    hideOnEmpty: true,
                                    hideOnLoading: true,
                                    direction: AxisDirection.up,
                                    textFieldConfiguration: TextFieldConfiguration(
                                      controller: tagTextController,
                                      cursorColor: Colors.black,
                                      decoration: InputDecoration(
                                        hintText: "Search for Tags",
                                        border: InputBorder.none,
                                      ),
                                      autofocus: false,
                                    ),
                                    suggestionsCallback: (searchTerm) async {
                                      return await AlgoliaSearch().queryTags(searchTerm);
                                    },
                                    itemBuilder: (context, tag) {
                                      return ListTile(
                                        title: Text(
                                          tag,
                                          style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.w700),
                                        ),
                                      );
                                    },
                                    onSuggestionSelected: (tag) {
                                      if (!tags.contains(tag)) {
                                        if (tags.length < 3) {
                                          tags.add(tag);
                                          setState(() {});
                                        } else {
                                          showOkAlertDialog(
                                            context: context,
                                            message: "Tag Limit Reached",
                                            okLabel: "Ok",
                                            barrierDismissible: true,
                                          );
                                        }
                                      }
                                      tagTextController.clear();
                                    },
                                  ),
                                ),
                                //EVENT LOCATION
                                SizedBox(height: 16.0),
                                fieldHeader("Audience Location", true),
                                postLocationField(),
                                SizedBox(height: 16.0),
                                //POST BODY
                                fieldHeader("Message", true),
                                postBodyField(),

                                // widget.isStream ? fieldHeader("Stream Category", true) : fieldHeader("Event Category", true),
                                // postCategory(),
                                SizedBox(height: 32.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 2.0),
                                      child: CustomColorButton(
                                        text: widget.postID == null ? "Create Post" : "Update Post",
                                        textColor: Colors.black,
                                        backgroundColor: Colors.white,
                                        height: 35.0,
                                        width: 150,
                                        onPressed: () => validateAndSubmitPost(),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 64.0),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

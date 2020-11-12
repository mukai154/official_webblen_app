import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/constants/strings.dart';
import 'package:webblen/firebase/data/reward_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/firebase/services/auth.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:webblen/widgets/common/alerts/custom_alerts.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/containers/text_field_container.dart';
import 'package:webblen/widgets/common/state/progress_indicator.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';

class CreateShopItemPage extends StatefulWidget {
  final String rewardID;
  CreateShopItemPage({this.rewardID});

  @override
  _CreateShopItemPageState createState() => _CreateShopItemPageState();
}

class _CreateShopItemPageState extends State<CreateShopItemPage> {
  String currentUID;
  WebblenUser currentUser;
  bool isLoading = true;
  bool isTypingMultiLine = false;
  ScrollController scrollController = ScrollController();
  TextEditingController messageTextController = TextEditingController();
  TextEditingController tagTextController = TextEditingController();
  GlobalKey formKey = GlobalKey<FormState>();
  MoneyMaskedTextController moneyMaskedTextController = MoneyMaskedTextController(
    leftSymbol: "",
    precision: 2,
    decimalSeparator: '.',
    thousandSeparator: ',',
  );

  //REWARD DETAILS
  WebblenReward reward;
  String type = 'giftCard';
  String providerID;
  String title;
  String description;
  String imgURL;
  File imgFile;
  int amountAvailable;
  double cost;
  String url;

  //Location Details
  double lat;
  double lon;
  String address;
  String city;
  String province = "AL";
  String zipPostalCode;
  List nearbyZipcodes = [];
  List<String> types = ['giftCard', 'cash', 'donation', 'webblen', 'webblenClothes'];

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
    address = detail.result.formattedAddress;
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

  ///IMG
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
        child: widget.rewardID != null && imgURL != null
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
                    ],
                  )
                : Image.file(
                    imgFile,
                    fit: BoxFit.contain,
                  ),
      ),
    );
  }

  ///LOCATION
  Widget locationField() {
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
                text: address == null || address.isEmpty ? "Search for Address" : address,
                textColor: address == null || address.isEmpty ? Colors.black54 : Colors.black,
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

  Widget clearAddressButton() {
    return GestureDetector(
      onTap: () {
        address = null;
        zipPostalCode = null;
        setState(() {});
      },
      child: Text(
        "Clear Address",
        style: TextStyle(
          fontSize: 18,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ///TITLE
  Widget titleField() {
    return TextFieldContainer(
      child: TextFormField(
        onTap: () {},
        initialValue: title,
        cursorColor: Colors.black,
        validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
        onChanged: (value) {
          setState(() {
            title = value.trim();
          });
        },
        onSaved: (value) => title = value.trim(),
        inputFormatters: [
          LengthLimitingTextInputFormatter(75),
        ],
        decoration: InputDecoration(
          hintText: "Reward Title",
          border: InputBorder.none,
        ),
      ),
    );
  }

  ///BODY
  Widget bodyField() {
    return TextFieldContainer(
      child: TextFormField(
        onTap: () {
          isTypingMultiLine = true;
          setState(() {});
        },
        initialValue: description,
        cursorColor: Colors.black,
        validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
        maxLines: 1,
        maxLength: 100,
        onChanged: (value) {
          setState(() {
            description = value.trim();
          });
        },
        decoration: InputDecoration(
          hintText: "Reward Description",
          border: InputBorder.none,
        ),
      ),
    );
  }

  ///COST
  Widget costField() {
    return TextFieldContainer(
      width: 70,
      child: TextFormField(
        onTap: () {
          isTypingMultiLine = false;
          setState(() {});
        },
        controller: moneyMaskedTextController,
        cursorColor: Colors.black,
        validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
        onSaved: (value) => cost = double.parse(value.trim()),
        decoration: InputDecoration(
          hintText: "\$9.99",
          border: InputBorder.none,
        ),
      ),
    );
  }

  ///TYPE
  Widget typeDropdown() {
    return Row(
      children: <Widget>[
        TextFieldContainer(
          height: 45,
          width: 300,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: DropdownButton(
                isExpanded: true,
                underline: Container(),
                value: type,
                items: types.map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    type = val;
                  });
                }),
          ),
        ),
      ],
    );
  }

  //CREATE EVENT
  submit() async {
    CustomAlerts().showLoadingAlert(context, "Uploading Reward...");
    WebblenReward reward = WebblenReward(
      id: widget.rewardID == null ? null : widget.rewardID,
      type: type,
      title: title,
      description: description,
      nearbyZipcodes: nearbyZipcodes,
      imageURL: imgURL == null ? "" : imgURL,
      expirationDate: "",
      amountAvailable: amountAvailable,
      isGlobalReward: zipPostalCode == null || zipPostalCode.isEmpty ? true : false,
      providerID: providerID,
      url: url,
      cost: cost,
    );
    RewardDataService().uploadReward(reward, zipPostalCode, imgFile).then((res) {
      if (res != null) {
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
                        'Reward Uploaded!',
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Reward is Available in Shop",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [],
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

  validateAndSubmit() {
    FormState formState = formKey.currentState;
    formState.save();
    if (title == null || title.isEmpty) {
      showOkAlertDialog(
        context: context,
        message: "Title Missing",
        okLabel: "Ok",
        barrierDismissible: true,
      );
    } else if (description == null || description.isEmpty) {
      showOkAlertDialog(
        context: context,
        message: "Description Missing",
        okLabel: "Ok",
        barrierDismissible: true,
      );
    } else {
      submit();
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
          setState(() {});
        });
      }
      // if (widget.postID != null) {
      //   PostDataService().getPost(widget.postID).then((res) {
      //     print(res.tags);
      //     if (res != null) {
      //       body = res.body;
      //       imgURL = res.imageURL == null ? null : res.imageURL;
      //       zipPostalCode = res.nearbyZipcodes.first;
      //       originalPostTimeInMilliseconds = res.postDateTimeInMilliseconds;
      //       tags = res.tags;
      //       sharedComs = res.sharedComs;
      //       originallySavedBy = res.savedBy;
      //       commentCount = res.commentCount;
      //       participantIDs = res.participantIDs;
      //       paidOut = res.paidOut;
      //       reported = res.reported;
      //     }
      //     isLoading = false;
      //     setState(() {});
      //   });
      // } else {
      //   isLoading = false;
      //   setState(() {});
      // }
      isLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().newEventAppBar(
          context, widget.rewardID != null ? 'Editing Reward' : 'New Reward', widget.rewardID != null ? 'Cancel Editing Reward?' : 'Cancel Adding New Reward?',
          () {
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
                          SizedBox(height: 16.0),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                //LOCATION
                                SizedBox(height: 16.0),
                                fieldHeader("Reward Location", false),
                                locationField(),
                                SizedBox(height: 8.0),
                                clearAddressButton(),
                                SizedBox(height: 16.0),
                                //POST BODY
                                fieldHeader("Title", true),
                                titleField(),
                                SizedBox(height: 16.0),
                                fieldHeader("Description", true),
                                bodyField(),
                                SizedBox(height: 16.0),
                                fieldHeader("Webblen Cost", true),
                                costField(),
                                SizedBox(height: 16.0),
                                fieldHeader("Type", true),
                                typeDropdown(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 2.0),
                                      child: CustomColorButton(
                                        text: widget.rewardID == null ? "Create Reward" : "Update Reward",
                                        textColor: Colors.black,
                                        backgroundColor: Colors.white,
                                        height: 35.0,
                                        width: 150,
                                        onPressed: () => validateAndSubmit(),
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

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/constants/strings.dart';
import 'package:webblen/firebase/data/reward_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/models/webblen_reward.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/containers/text_field_container.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';

class ShopItemDetailsPage extends StatefulWidget {
  final WebblenUser currentUser;
  final WebblenReward reward;
  ShopItemDetailsPage({this.currentUser, this.reward});

  @override
  _ShopItemDetailsPageState createState() => _ShopItemDetailsPageState();
}

class _ShopItemDetailsPageState extends State<ShopItemDetailsPage> {
  bool isLoading;
  String email;
  String address1;
  String address2;
  String cashRewardUsername;
  String cashRewardUsernameConfirmation;
  double purchaseTotal;
  String selectedSize = 'M';
  List<String> availableSizes = ['XS', 'S', 'M', 'L', 'XL'];
  final GlobalKey<FormState> merchFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> cashFormKey = GlobalKey<FormState>();

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
    address1 = detail.result.formattedAddress;
    setState(() {});
  }

  purchaseReward() {
    if (widget.reward.type == "webblenClothes") {
      submitMerchForm();
    } else {
      submitCashForm();
    }
  }

  submitMerchForm() {
    merchFormKey.currentState.save();
    if (email == null || !Strings().isEmailValid(email)) {
      showAlertDialog(
        context: context,
        message: "Email Invalid",
        barrierDismissible: true,
        actions: [
          AlertDialogAction(label: "Ok", isDefaultAction: true),
        ],
      );
    } else if (address1 == null || address1.isEmpty) {
      showAlertDialog(
        context: context,
        message: "Address Required",
        barrierDismissible: true,
        actions: [
          AlertDialogAction(label: "Ok", isDefaultAction: true),
        ],
      );
    } else {
      RewardDataService().purchaseReward(widget.currentUser.uid, widget.reward.cost).then((e) {
        if (e == null) {
          RewardDataService()
              .purchaseMerchReward(
            widget.currentUser.uid,
            widget.reward.type,
            widget.reward.title,
            widget.reward.id,
            selectedSize,
            email,
            address1,
            address2,
          )
              .then((e) async {
            if (e == null) {
              String res = await showAlertDialog(
                context: context,
                message: "Purchase Successful!",
                barrierDismissible: false,
                actions: [
                  AlertDialogAction(label: "Ok", key: "ok", isDefaultAction: true),
                ],
              );
              if (res == "ok") {
                Navigator.of(context).pop();
              }
            } else {
              WebblenUserData().depositWebblen(widget.reward.cost, widget.currentUser.uid);
              showAlertDialog(
                context: context,
                message: "There Was an Issue Completing Your Order. Please Try Again.",
                barrierDismissible: true,
                actions: [
                  AlertDialogAction(label: "Ok", isDefaultAction: true),
                ],
              );
            }
          });
        } else {
          showAlertDialog(
            context: context,
            message: "Insufficient Funds",
            barrierDismissible: true,
            actions: [
              AlertDialogAction(label: "Ok", isDefaultAction: true),
            ],
          );
        }
      });
    }
  }

  submitCashForm() {
    merchFormKey.currentState.save();
    if (!widget.reward.title.contains("PayPal") && email == null || !Strings().isEmailValid(email)) {
      showAlertDialog(
        context: context,
        message: "Email Invalid",
        barrierDismissible: true,
        actions: [
          AlertDialogAction(label: "Ok", isDefaultAction: true),
        ],
      );
    } else if (cashRewardUsername == null || cashRewardUsername.isEmpty) {
      showAlertDialog(
        context: context,
        message: "Username Required",
        barrierDismissible: true,
        actions: [
          AlertDialogAction(label: "Ok", isDefaultAction: true),
        ],
      );
    } else if (cashRewardUsername != cashRewardUsernameConfirmation) {
      showAlertDialog(
        context: context,
        message: "Usernames Do Not Match",
        barrierDismissible: true,
        actions: [
          AlertDialogAction(label: "Ok", isDefaultAction: true),
        ],
      );
    } else {
      RewardDataService().purchaseReward(widget.currentUser.uid, widget.reward.cost).then((e) {
        if (e == null) {
          RewardDataService()
              .purchaseCashReward(
            widget.currentUser.uid,
            widget.reward.type,
            widget.reward.title,
            widget.reward.id,
            cashRewardUsername,
            email,
          )
              .then((e) async {
            if (e == null) {
              String res = await showAlertDialog(
                context: context,
                message: "Purchase Successful!",
                barrierDismissible: false,
                actions: [
                  AlertDialogAction(label: "Ok", key: "ok", isDefaultAction: true),
                ],
              );
              if (res == "ok") {
                Navigator.of(context).pop();
              }
            } else {
              WebblenUserData().depositWebblen(widget.reward.cost, widget.currentUser.uid);
              showAlertDialog(
                context: context,
                message: "There Was an Issue Completing Your Order. Please Try Again.",
                barrierDismissible: true,
                actions: [
                  AlertDialogAction(label: "Ok", isDefaultAction: true),
                ],
              );
            }
          });
        } else {
          showAlertDialog(
            context: context,
            message: "Insufficient Funds",
            barrierDismissible: true,
            actions: [
              AlertDialogAction(label: "Ok", isDefaultAction: true),
            ],
          );
        }
      });
    }
  }

  Widget fieldHeader(String header, bool isRequired) {
    return isRequired
        ? Row(
            children: [
              Text(
                header,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.w500),
              ),
              Text(
                "*",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16.0, color: Colors.red, fontWeight: FontWeight.w500),
              )
            ],
          )
        : Row(
            children: [
              Text(
                header,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.w500),
              )
            ],
          );
  }

  Widget sizeDropdown() {
    return Row(
      children: <Widget>[
        TextFieldContainer(
          height: 45,
          width: 50,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: DropdownButton(
                isExpanded: true,
                underline: Container(),
                value: selectedSize,
                items: availableSizes.map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedSize = val;
                  });
                }),
          ),
        ),
      ],
    );
  }

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
                text: address1 == null || address1.isEmpty ? "Search for Address" : address1,
                textColor: address1 == null || address1.isEmpty ? Colors.black54 : Colors.black,
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

  Widget emailField() {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: email,
        cursorColor: Colors.black,
        validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
        onChanged: (value) {
          setState(() {
            email = value.trim();
          });
        },
        onSaved: (value) => email = value.trim(),
        decoration: InputDecoration(
          hintText: "example@email.com",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget address2Field() {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: address2,
        cursorColor: Colors.black,
        validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
        onChanged: (value) {
          setState(() {
            address2 = value.trim();
          });
        },
        onSaved: (value) => address2 = value.trim(),
        decoration: InputDecoration(
          hintText: "Optional",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget cashRewardUsernameField() {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: cashRewardUsername,
        cursorColor: Colors.black,
        validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
        onChanged: (value) {
          setState(() {
            cashRewardUsername = value.trim();
          });
        },
        onSaved: (value) => cashRewardUsername = value.trim(),
        decoration: InputDecoration(
          hintText: widget.reward.title.contains("Cash App")
              ? "\$username"
              : widget.reward.title.contains("Venmo")
                  ? "@username"
                  : "example@email.com",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget confirmCashRewardUsernameField() {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: cashRewardUsernameConfirmation,
        cursorColor: Colors.black,
        validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
        onChanged: (value) {
          setState(() {
            cashRewardUsernameConfirmation = value.trim();
          });
        },
        onSaved: (value) => cashRewardUsernameConfirmation = value.trim(),
        decoration: InputDecoration(
          hintText: widget.reward.title.contains("Cash App")
              ? "\$username"
              : widget.reward.title.contains("Venmo")
                  ? "@username"
                  : "example@email.com",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget merchRewardForm() {
    return Form(
      key: merchFormKey,
      child: Column(
        children: [
          fieldHeader("Size", true),
          SizedBox(height: 4),
          sizeDropdown(),
          SizedBox(height: 24),
          fieldHeader("Email Address", true),
          SizedBox(height: 4),
          emailField(),
          SizedBox(height: 24),
          fieldHeader("Street Address", true),
          SizedBox(height: 4),
          locationField(),
          SizedBox(height: 24),
          fieldHeader("Apt, Suite, No.", false),
          SizedBox(height: 4),
          address2Field(),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget cashRewardForm() {
    return Form(
      key: cashFormKey,
      child: Column(
        children: [
          widget.reward.title.contains("PayPal") ? Container() : fieldHeader("Email Address", true),
          widget.reward.title.contains("PayPal") ? Container() : SizedBox(height: 4),
          widget.reward.title.contains("PayPal") ? Container() : emailField(),
          widget.reward.title.contains("PayPal") ? Container() : SizedBox(height: 24),
          fieldHeader(
            widget.reward.title.contains("Cash App")
                ? "Cash App Tag"
                : widget.reward.title.contains("Venmo")
                    ? "Venmo Username"
                    : "PayPal Email",
            true,
          ),
          SizedBox(height: 4),
          cashRewardUsernameField(),
          SizedBox(height: 24),
          fieldHeader(
            widget.reward.title.contains("Cash App")
                ? "Confirm Cash App Tag"
                : widget.reward.title.contains("Venmo")
                    ? "Confirm Venmo Username"
                    : "Confirm PayPal Email",
            true,
          ),
          SizedBox(height: 4),
          confirmCashRewardUsernameField(),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ** APP BAR
    final appBar = AppBar(
      elevation: 0.5,
      brightness: Brightness.light,
      backgroundColor: Color(0xFFF9F9F9),
      title: Text(
        "Details",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black, fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      //Text('Shop', style: Fonts.dashboardTitleStyle),
      leading: BackButton(
        color: Colors.black,
      ),
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4.0,
          ),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("webblen_user").doc(widget.currentUser.uid).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
              if (!userSnapshot.hasData)
                return Text(
                  "Loading...",
                );
              var userData = userSnapshot.data.data();
              double availablePoints = userData['d']["eventPoints"] * 1.00;
              return Padding(
                padding: EdgeInsets.all(4.0),
                child: Row(
                  children: <Widget>[
                    Image.asset(
                      'assets/images/webblen_coin.png',
                      height: 24.0,
                      width: 24.0,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      availablePoints.toStringAsFixed(2),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: CachedNetworkImage(
                imageUrl: widget.reward.imageURL,
                fit: BoxFit.contain,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16.0),
                  Text(
                    widget.reward.title,
                    textAlign: TextAlign.start,
                    style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/images/webblen_coin.png',
                            height: 20.0,
                            width: 20.0,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            widget.reward.cost.toStringAsFixed(2),
                            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  widget.reward.type == "webblenClothes" ? merchRewardForm() : cashRewardForm(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80.0,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: CustomColors.textFieldGray,
              width: 1.5,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Total",
                    style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/webblen_coin.png',
                        height: 20.0,
                        width: 20.0,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(
                        width: 4.0,
                      ),
                      Text(
                        widget.reward.cost.toStringAsFixed(2),
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomColorButton(
                    text: "Purchase",
                    textSize: 14.0,
                    textColor: Colors.white,
                    backgroundColor: CustomColors.darkMountainGreen,
                    height: 35.0,
                    width: MediaQuery.of(context).size.width * 0.4,
                    onPressed: () => purchaseReward(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

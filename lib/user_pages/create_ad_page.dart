import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'dart:io';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:webblen/widgets_common/common_flushbar.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/local_ad.dart';
import 'package:webblen/firebase_services/ad_data.dart';
import 'package:flutter/services.dart';
import 'package:webblen/services_general/services_location.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/open_url.dart';

class CreateAdPage extends StatefulWidget {

  final WebblenUser currentUser;
  CreateAdPage({this.currentUser});

  @override
  State<StatefulWidget> createState() {
    return _CreateAdPageState();
  }
}

class _CreateAdPageState extends State<CreateAdPage> {

  final GlobalKey<FormState> adFormKey = GlobalKey<FormState>();

  double currentLat;
  double currentLon;
  LocalAd localAd = LocalAd();
  File adImage;
  bool urlIsValid;

  //Form Validations
  void validateAndSubmit() async {
    final form = adFormKey.currentState;
    form.save();
    if (currentLat == null){
      AlertFlushbar(headerText: "Error", bodyText: "There was an issue finding your location. Please try again.").showAlertFlushbar(context);
    } else if (localAd.adURL == null || localAd.adURL.isEmpty) {
      AlertFlushbar(headerText: "Error", bodyText: "Ad Needs a URL").showAlertFlushbar(context);
    } else {
      urlIsValid = OpenUrl().isValidUrl(localAd.adURL);
      if (urlIsValid){
        ShowAlertDialogService().showLoadingDialog(context);
        localAd.authorUid = widget.currentUser.uid;
        localAd.clicks = 0;
        localAd.impressions = 0;
        localAd.datePostedInMilliseconds = DateTime.now().millisecondsSinceEpoch;
        AdDataService().uploadAd(adImage, localAd, currentLat, currentLon).then((error){
          if (error.isEmpty){
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pop();
            ShowAlertDialogService().showFailureDialog(context, 'Uh Oh', 'There was an issue uploading your ad. Please try again.');
          }
        });
      } else {
        AlertFlushbar(headerText: "Error", bodyText: "Ad URL is Invalid").showAlertFlushbar(context);
      }
    }
  }

  void setAdImage(bool getImageFromCamera) async {
    setState(() {
      adImage = null;
    });
    Navigator.of(context).pop();
    adImage = getImageFromCamera
        ? await WebblenImagePicker(context: context, ratioX: 1.0, ratioY: 1.0).retrieveImageFromCamera()
        : await WebblenImagePicker(context: context, ratioX: 1.0, ratioY: 1.0).retrieveImageFromLibrary();
    if (adImage != null){
      setState(() {});
    }
  }


  @override
  void initState() {
    super.initState();
    LocationService().getCurrentLocation(context).then((result){
      if (this.mounted){
        if (result != null){
          currentLat = result.latitude;
          currentLon = result.longitude;
          setState(() {});
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    Widget addImageButton() {
      return GestureDetector(
        onTap: () => ShowAlertDialogService().showImageSelectDialog(context, () => setAdImage(true), () => setAdImage(false)),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Colors.black12
          ),
          child: adImage == null
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.camera_alt, size: 40.0, color: FlatColors.londonSquare),
              Fonts().textW500('1:1', 16.0, FlatColors.londonSquare, TextAlign.center)
            ],
          )
              : Image.file(adImage, fit: BoxFit.cover),
        ),
      );
    }

    Widget _buildUrlField(){
      return Container(
        margin: EdgeInsets.only(left: 16.0, top: 4.0, right: 8.0),
        child: new TextFormField(
          initialValue: "",
          maxLines: 1,
          style: TextStyle(color: Colors.black54, fontSize: 16.0, fontFamily: 'Barlow', fontWeight: FontWeight.w500),
          autofocus: false,
          onSaved: (value) => localAd.adURL = value,
          inputFormatters: [
            BlacklistingTextInputFormatter(RegExp("[\\ |\\,]"))
          ],
          decoration: InputDecoration(
            icon: Icon(Icons.link, color: FlatColors.darkGray, size: 18),
            border: InputBorder.none,
            hintText: "Ad URL",
            counterStyle: TextStyle(fontFamily: 'Barlow'),
            contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
          ),
        ),
      );
    }

    final formView = Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Form(
            key: adFormKey,
            child: ListView(
              children: <Widget>[
                addImageButton(),
                _buildUrlField(),
                CustomColorButton(
                  text: "Submit",
                  textColor: FlatColors.darkGray,
                  backgroundColor: Colors.white,
                  height: 45.0,
                  width: 150.0,
                  hPadding: 16.0,
                  vPadding: 16.0,
                  onPressed: () => validateAndSubmit(),
                )
              ],
            ),
          )
      ),
    );

    return Scaffold(
        appBar: WebblenAppBar().basicAppBar("New Ad"),
        body: formView
    );
  }

}
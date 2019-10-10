import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'dart:io';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:webblen/widgets_common/common_flushbar.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'package:flutter/services.dart';
import 'package:webblen/services_general/services_location.dart';
import 'package:webblen/styles/fonts.dart';

class CreateFlashEventPage extends StatefulWidget {

  final WebblenUser currentUser;
  CreateFlashEventPage({this.currentUser});

  @override
  State<StatefulWidget> createState() {
    return _CreateFlashEventPageState();
  }
}

class _CreateFlashEventPageState extends State<CreateFlashEventPage> {

  final GlobalKey<FormState> page1FormKey = GlobalKey<FormState>();

  //Event
  double currentLat;
  double currentLon;
  Event newEvent = Event(radius: 0.25);
  File eventImage;
  int eventTypeRadioVal = 0;

  //Form Validations
  void validateAndSubmit() async {
    final form = page1FormKey.currentState;
    form.save();
    newEvent.eventType = getRadioValue();
    if (currentLat == null){
      AlertFlushbar(headerText: "Error", bodyText: "There was an issue finding your location. Please try again.").showAlertFlushbar(context);
    } else if (newEvent.title == null || newEvent.title.isEmpty) {
      AlertFlushbar(headerText: "Error", bodyText: "Event Title Cannot be Empty").showAlertFlushbar(context);
    } else if (newEvent.description == null || newEvent.description.isEmpty){
      AlertFlushbar(headerText: "Error", bodyText: "Event Description Cannot Be Empty").showAlertFlushbar(context);
    } else if (eventImage == null) {
      AlertFlushbar(headerText: "Error", bodyText: "Image is Required").showAlertFlushbar(context);
    } else {
      ShowAlertDialogService().showLoadingDialog(context);
      newEvent.authorUid = "";
      newEvent.attendees = [];
      newEvent.privacy = 'public';
      newEvent.flashEvent = true;
      newEvent.eventPayout = 0.00;
      newEvent.estimatedTurnout = 0;
      newEvent.actualTurnout = 0;
      newEvent.pointsDistributedToUsers = false;
      newEvent.views = 0;
      newEvent.recurrence = 'none';
      newEvent.tags = [];
      newEvent.fbSite = "";
      newEvent.twitterSite = "";
      newEvent.website = "";
      newEvent.address = await LocationService().getAddressFromLatLon(currentLat, currentLon);
      newEvent.startDateInMilliseconds = DateTime.now().millisecondsSinceEpoch;
      newEvent.endDateInMilliseconds = DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch;
      EventDataService().uploadEvent(eventImage, newEvent, currentLat, currentLon).then((error){
        if (error.isEmpty){
          Navigator.of(context).pop();
          HapticFeedback.mediumImpact();
          ShowAlertDialogService().showActionSuccessDialog(context, 'Flash Event Created!', 'Check In. Get Paid. You Know the Rest...', (){
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          });
        } else {
          Navigator.of(context).pop();
          ShowAlertDialogService().showFailureDialog(context, 'Uh Oh', 'There was an issue uploading your event. Please try again.');
        }
      });
    }
  }

  void setEventImage(bool getImageFromCamera) async {
    setState(() {
      eventImage = null;
    });
    Navigator.of(context).pop();
    eventImage = getImageFromCamera
      ? await WebblenImagePicker(context: context, ratioX: 1.0, ratioY: 1.0).retrieveImageFromCamera()
      : await WebblenImagePicker(context: context, ratioX: 1.0, ratioY: 1.0).retrieveImageFromLibrary();
    if (eventImage != null){
      setState(() {});
    }
  }

  void handleRadioValueChanged(int value) {
    setState(() {
      eventTypeRadioVal = value;
    });
  }

  String getRadioValue(){
    String val = 'standard';
    if (eventTypeRadioVal == 1){
      val = 'foodDrink';
    } else if (eventTypeRadioVal == 2) {
      val = 'saleDiscount';
    }
    return val;
  }

  Widget _buildRadioButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CustomColorButton(
                    height: 30.0,
                    width: 110.0,
                    hPadding: 0,
                    text: 'standard',
                    textColor: eventTypeRadioVal == 0 ? Colors.white : Colors.black,
                    backgroundColor: eventTypeRadioVal == 0 ? FlatColors.webblenRed : FlatColors.textFieldGray,
                    onPressed: () {
                      eventTypeRadioVal = 0;
                      setState(() {});
                    },
                  ),
                  CustomColorButton(
                    height: 30.0,
                    width: 110.0,
                    hPadding: 0,
                    text: 'food/drink',
                    textColor: eventTypeRadioVal == 1 ? Colors.white : Colors.black,
                    backgroundColor: eventTypeRadioVal == 1 ? FlatColors.webblenRed : FlatColors.textFieldGray,
                    onPressed: () {
                      eventTypeRadioVal = 1;
                      setState(() {});
                    },
                  ),
                  CustomColorButton(
                    height: 30.0,
                    width: 110.0,
                    hPadding: 0,
                    text: 'sale/discount',
                    textColor: eventTypeRadioVal == 2 ? Colors.white : Colors.black,
                    backgroundColor: eventTypeRadioVal == 2 ? FlatColors.webblenRed : FlatColors.textFieldGray,
                    onPressed: () {
                      eventTypeRadioVal = 2;
                      setState(() {});
                    },
                  ),
                ]
            ),
          ]
      ),
    );
  }



  @override
  void initState() {
    // TODO: implement initState
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
        onTap: () => ShowAlertDialogService().showImageSelectDialog(context, () => setEventImage(true), () => setEventImage(false)),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Colors.black12
          ),
          child: eventImage == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.camera_alt, size: 40.0, color: FlatColors.londonSquare),
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                      child: Fonts().textW500('1:1', 16.0, FlatColors.londonSquare, TextAlign.center)
                    ),
                  ],
                )
              : Image.file(eventImage, fit: BoxFit.cover),
        ),
      );
    }


    Widget _buildEventTitleField(){
      return Container(
        margin: EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        decoration: BoxDecoration(
          color: FlatColors.textFieldGray,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: TextFormField(
              decoration: InputDecoration(
                hintText: "Event Title",
                contentPadding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
                border: InputBorder.none,
              ),
              onSaved: (value) => newEvent.title = value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontFamily: "Helvetica Neue",
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              inputFormatters: [
                LengthLimitingTextInputFormatter(30),
                BlacklistingTextInputFormatter(RegExp("[\\-|\\#|\\[|\\]|\\%|\\^|\\*|\\+|\\=|\\_|\\~|\\<|\\>|\\,|\\@|\\(|\\)|\\'|\\{|\\}|\\.]"))
              ],
              textInputAction: TextInputAction.done,
              autocorrect: false,
            ),
        ),
      );
    }

    Widget _buildEventDescriptionField(){
      return Container(
        height: 180,
        margin: EdgeInsets.only(left: 8, right: 8, bottom: 16),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 16
        ),
        decoration: BoxDecoration(
          color: FlatColors.textFieldGray,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: TextFormField(
              decoration: InputDecoration(
                hintText: "Event Description",
                contentPadding: EdgeInsets.all(8),
                border: InputBorder.none,
              ),
              onSaved: (val) => newEvent.description = val,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: "Helvetica Neue",
              ),
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              autocorrect: false,
            ),
        ),
      );
    }



    //**Title, Description, Dates, URLS
    final formView = Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Form(
            key: page1FormKey,
            child: ListView(
              children: <Widget>[
                addImageButton(),
                _buildEventTitleField(),
                SizedBox(height: 8.0),
                _buildEventDescriptionField(),
                Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                    child: Fonts().textW700("Event Type", 18.0, FlatColors.darkGray, TextAlign.left),
                  ),
                ),
                _buildRadioButtons(),
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
      appBar: WebblenAppBar().basicAppBar("New Flash Event", context),
      body: formView
    );
  }

}
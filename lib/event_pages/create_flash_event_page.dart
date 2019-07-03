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
import 'package:webblen/firebase_services/event_data.dart';
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

  //Form Validations
  void validateAndSubmit() async {
    final form = page1FormKey.currentState;
    form.save();
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
          Navigator.of(context).pop();
          Navigator.of(context).pop();
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
      ? await WebblenImagePicker(context: context, ratioX: 9.0, ratioY: 7.0).retrieveImageFromCamera()
      : await WebblenImagePicker(context: context, ratioX: 9.0, ratioY: 7.0).retrieveImageFromLibrary();
    if (eventImage != null){

      setState(() {});
    }
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
          height: 300.0,
          decoration: BoxDecoration(
              color: Colors.black12
          ),
          child: eventImage == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.camera_alt, size: 40.0, color: FlatColors.londonSquare),
                    Fonts().textW500('900 x 700', 16.0, FlatColors.londonSquare, TextAlign.center)
                  ],
                )
              : Image.file(eventImage, fit: BoxFit.cover),
        ),
      );
    }


    Widget _buildEventTitleField(){
      return new Container(
        margin: EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: new TextFormField(
          maxLengthEnforced: true,
          cursorColor: FlatColors.darkGray,
          style: TextStyle(color: FlatColors.darkGray, fontSize: 30.0, fontFamily: 'Nunito', fontWeight: FontWeight.w800),
          autofocus: false,
          inputFormatters: [
            LengthLimitingTextInputFormatter(30),
          ],
          onSaved: (value) => newEvent.title = value,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Event Title",
            counterStyle: TextStyle(fontFamily: 'Nunito'),
            contentPadding: EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
          ),
        ),
      );
    }

    Widget _buildEventDescriptionField(){
      return Container(
        margin: EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        height: 150.0,
        child: new TextFormField(
          maxLines: 5,
          maxLength: 300,
          cursorColor: FlatColors.darkGray,
          style: TextStyle(color: Colors.black54, fontSize: 18.0, fontFamily: 'Barlow', fontWeight: FontWeight.w500),
          maxLengthEnforced: true,
          autofocus: false,
          onSaved: (value) => newEvent.description = value,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Event Description",
            counterStyle: TextStyle(fontFamily: 'Barlow'),
            contentPadding: EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 10.0),
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
                _buildEventDescriptionField(),
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
      appBar: WebblenAppBar().basicAppBar("New Flash Event"),
      body: formView
    );
  }

}
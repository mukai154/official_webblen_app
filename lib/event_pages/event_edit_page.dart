//import 'package:flutter/material.dart';
//import 'package:webblen/models/event.dart';
//import 'package:webblen/utils/open_url.dart';
//import 'package:webblen/styles/fonts.dart';
//import 'package:webblen/styles/flat_colors.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:webblen/utils/image_caching.dart';
//import 'dart:io';
//import 'package:webblen/models/webblen_user.dart';
//import 'package:webblen/utils/create_notification.dart';
//import 'package:webblen/utils/device_calendar.dart';
//import 'package:webblen/widgets_icons/icon_bubble.dart';
//import 'package:webblen/widgets_common/common_appbar.dart';
//import 'package:webblen/utils/payment_calc.dart';
//import 'package:webblen/widgets_common/common_button.dart';
//import 'package:webblen/firebase_services/event_data.dart';
//import 'package:webblen/utils/webblen_image_picker.dart';
//import 'package:intl/intl.dart';
//import 'package:webblen/services_general/services_show_alert.dart';
//
//class EventEditPage extends StatefulWidget {
//
//  final Event event;
//  final WebblenUser currentUser;
//  final bool eventIsLive;
//  EventEditPage({this.event, this.currentUser, this.eventIsLive});
//
//  @override
//  _EventEditPageState createState() => _EventEditPageState();
//}
//
//class _EventEditPageState extends State<EventEditPage> {
//
//  File eventImage;
//  File newEventImage;
//  Event newEvent = Event();
//  TimeOfDay currentTime = TimeOfDay.now();
//  final eventFormKey = new GlobalKey<FormState>();
//  final detailsScaffoldKey = GlobalKey<ScaffoldState>();
//  final searchScaffoldKey = GlobalKey<ScaffoldState>();
//
//  void imagePicker() async {
//    File img = await WebblenImagePicker(context: context, ratioX: 9.0, ratioY: 7.0).initializeImagePickerCropper();
//    if (img != null) {
//      newEventImage = img;
//      setState(() {});
//    }
//  }
//
//  void handleNewDate(DateTime selectedDate) {
//    ScaffoldState scaffold = detailsScaffoldKey.currentState;
//    DateTime invalidDate = DateTime.now().subtract(Duration(hours: 8));
//    if (selectedDate.isBefore(invalidDate)) {
//      scaffold.showSnackBar(SnackBar(
//        content: Text("Invalid Event Date"),
//        backgroundColor: Colors.red,
//        duration: Duration(milliseconds: 800),
//      ));
//    } else {
//      newEvent.startDateInMilliseconds = selectedDate.millisecondsSinceEpoch;
//    }
//  }
//
//  Widget _buildCalendar(){
//    DateFormat formatter = DateFormat('MM/dd/yyyy');
//    return Theme(
//      data: ThemeData(
//        primaryColor: FlatColors.webblenRed,
//        accentColor: FlatColors.webblenRed,
//      ),
//      child: Container(
//        margin: EdgeInsets.symmetric(
//          horizontal: 16.0,
//          vertical: 8.0,
//        ),
//        padding: EdgeInsets.all(16.0),
//        decoration: BoxDecoration(
//            color: Colors.white,
//            borderRadius: BorderRadius.circular(16.0),
//            boxShadow: [BoxShadow(
//              color: Colors.black26,
//              blurRadius: 5.0,
//              offset: Offset(0.0, 5.0),
//            ),]
//        ),
//        child: Container() //calendar
//      ),
//    );
//  }
//
//  Future<Null> _selectTime(BuildContext context, bool startTime) async {
//    final TimeOfDay picked =  await showTimePicker(context: context, initialTime: currentTime);
//    if (picked != null){
//      setState(() {
//        if (startTime){
//          newEventPost.startTime = picked.format(context);
//        } else {
//          newEventPost.endTime = picked.format(context);
//        }
//      });
//    }
//  }
//
//  void validateEdits(){
//    ShowAlertDialogService().showLoadingDialog(context);
//    final form = eventFormKey.currentState;
//    form.save();
//    DateFormat timeFormatter = DateFormat("MM/dd/yyyy h:mm a");
//    DateTime startDateTime = timeFormatter.parse(newEventPost.startDate + " " + newEventPost.startTime);
//    String startDateInMilliseconds = startDateTime.millisecondsSinceEpoch.toString();
//    DateTime endDateTime = timeFormatter.parse(newEventPost.startDate + " " + newEventPost.endTime);
//    String endDateInMilliseconds =  endDateTime.millisecondsSinceEpoch.toString();
//    newEventPost.startDateInMilliseconds = startDateInMilliseconds;
//    newEventPost.endDateInMilliseconds = endDateInMilliseconds;
//    if (newEventImage != null){
//      EventPostService().updateEventWithImage(newEventPost, newEventImage).then((error){
//        Navigator.of(context).pop();
//        if (error.isNotEmpty){
//          ShowAlertDialogService().showFailureDialog(context, "Uh Oh", 'There was an issue editing this event. Please Try Again');
//        }
//      });
//    } else {
//      EventPostService().updateEvent(newEventPost).then((error){
//        Navigator.of(context).pop();
//        Navigator.of(context).pop();
//        if (error.isNotEmpty){
//          ShowAlertDialogService().showFailureDialog(context, "Uh Oh", 'There was an issue editing this event. Please Try Again');
//        }
//      });
//    }
//  }
//
//  Widget editForm(){
//    return ListView(
//      children: <Widget>[
//        Form(
//          key: eventFormKey,
//          child: Column(
//            children: <Widget>[
//              Container(
//                height: 300.0,
//                width: MediaQuery.of(context).size.width,
//                child: Stack(
//                  children: <Widget>[
//                    newEventImage == null
//                        ? eventImage == null
//                        ? Image.network(widget.eventPost.pathToImage, fit: BoxFit.cover, height: 300.0, width: MediaQuery.of(context).size.width)
//                        : Image.file(eventImage, fit: BoxFit.cover, height: 300.0, width: MediaQuery.of(context).size.width)
//                        : Image.file(newEventImage, fit: BoxFit.cover, height: 300.0, width: MediaQuery.of(context).size.width),
//                    Center(
//                      child: CustomColorIconButton(
//                        icon: Icon(FontAwesomeIcons.camera, size: 18.0, color: FlatColors.darkGray,),
//                        backgroundColor: Colors.white,
//                        height: 40.0,
//                        width: 40.0,
//                        onPressed: imagePicker,
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//              TextFormField(
//                textAlign: TextAlign.left,
//                initialValue: widget.eventPost.caption,
//                maxLines: 6,
//                autofocus: false,
//                style: TextStyle(fontFamily: 'Barlow', fontWeight: FontWeight.w400, fontSize: 16.0, color: FlatColors.lightAmericanGray),
//                onSaved: (value) => newEventPost.caption = value,
//                decoration: InputDecoration(
//                  border: InputBorder.none,
//                  hintText: "Event Details",
//                  counterStyle: TextStyle(fontFamily: 'Barlow', fontWeight: FontWeight.w400),
//                ),
//              ),
//              Padding(
//                padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    Fonts().textW700('Details', 24.0, FlatColors.darkGray, TextAlign.left),
//                    TextFormField(
//                      textAlign: TextAlign.center,
//                      initialValue: widget.eventPost.caption,
//                      maxLines: 6,
//                      autofocus: false,
//                      style: TextStyle(fontFamily: 'Barlow', fontWeight: FontWeight.w400, fontSize: 16.0, color: FlatColors.lightAmericanGray),
//                      onSaved: (value) => newEventPost.caption = value,
//                      decoration: InputDecoration(
//                        border: InputBorder.none,
//                        hintText: "Event Details",
//                        counterStyle: TextStyle(fontFamily: 'Barlow', fontWeight: FontWeight.w400),
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//              Padding(
//                padding: EdgeInsets.only(left: 16.0, top: 24.0),
//                child: widget.eventPost.flashEvent
//                    ? Container()
//                    : Row(
//                  children: <Widget>[
//                    Column(
//                      children: <Widget>[
//                        Icon(FontAwesomeIcons.calendar, size: 24.0, color: FlatColors.darkGray),
//                      ],
//                    ),
//                    SizedBox(width: 4.0),
//                    Column(
//                      children: <Widget>[
//                        SizedBox(height: 4.0),
//                        Fonts().textW500('${newEventPost.startDate} | ${newEventPost.startTime} - ${newEventPost.endTime}', 18.0, FlatColors.darkGray, TextAlign.left),
//                      ],
//                    ),
//                  ],
//                ),
//              ),
//              widget.eventPost.flashEvent || widget.eventIsLive
//                  ? Container()
//                  : _buildCalendar(),
//              widget.eventPost.flashEvent || widget.eventIsLive
//                  ? Container()
//                  : Padding(
//                padding: EdgeInsets.only(left: 16.0, top: 2.0),
//                child: InkWell(
//                  onTap: () => () => _selectTime(context, true),
//                  child: Fonts().textW400(' Set Start Time', 14.0, FlatColors.webblenDarkBlue, TextAlign.left),
//                ),
//              ),
//              widget.eventPost.flashEvent || widget.eventIsLive
//                  ? Container()
//                  : Padding(
//                padding: EdgeInsets.only(left: 16.0, top: 2.0),
//                child: InkWell(
//                  onTap: () => () => _selectTime(context, false),
//                  child: Fonts().textW400(' Set End Time', 14.0, FlatColors.webblenDarkBlue, TextAlign.left),
//                ),
//              ),
//              widget.eventIsLive
//                  ? Container()
//                  : Padding(
//                padding: EdgeInsets.only(left: 16.0, top: 16.0),
//                child: Row(
//                  crossAxisAlignment: CrossAxisAlignment.center,
//                  children: <Widget>[
//                    Column(
//                      children: <Widget>[
//                        Icon(FontAwesomeIcons.directions, size: 24.0, color: FlatColors.darkGray),
//                      ],
//                    ),
//                    SizedBox(width: 4.0),
//                    Column(
//                      children: <Widget>[
//                        SizedBox(height: 4.0),
//                        Fonts().textW500('${widget.eventPost.address.replaceAll(', USA', '')}', 18.0, FlatColors.darkGray, TextAlign.left),
//                      ],
//                    ),
//                  ],
//                ),
//              ),
//              widget.eventIsLive
//                  ? Container()
//                  : Padding(
//                padding: EdgeInsets.only(left: 16.0, top: 2.0),
//                child: Fonts().textW400(' Address Cannot Be Changed', 14.0, FlatColors.lightAmericanGray, TextAlign.left),
//              ),
//              CustomColorButton(
//                text: 'Update',
//                textColor: FlatColors.darkGray,
//                backgroundColor: Colors.white,
//                onPressed: validateEdits,
//              ),
//            ],
//          ),
//        ),
//      ],
//    );
//  }
//
//  @override
//  void initState() {
//    // TODO: implement initState
//    super.initState();
//    ImageCachingService().getCachedImage(widget.eventPost.pathToImage).then((imageFile){
//      if (imageFile != null){
//        eventImage = imageFile;
//        setState(() {});
//      }
//    });
//    newEventPost = widget.eventPost;
//    setState(() {});
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: WebblenAppBar().actionAppBar(
//          widget.eventPost.title,
//          widget.eventPost.author == "@" + widget.currentUser.username || widget.currentUser.isCommunityBuilder
//              ? IconButton(
//            icon: Icon(FontAwesomeIcons.ellipsisH, size: 24.0, color: FlatColors.darkGray),
//            onPressed: null,
//          )
//              : Container()
////          IconButton(
////            icon: Icon(FontAwesomeIcons.paperPlane, size: 24.0, color: FlatColors.darkGray),
////            onPressed: null,
////          ),
//      ),
//      body: editForm(),
//    );
//  }
//}
//

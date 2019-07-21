import 'package:flutter/material.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/widgets_common/common_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/styles/fonts.dart';
import 'dart:io';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:webblen/utils/strings.dart';
import 'package:webblen/services_general/services_location.dart';
import 'package:webblen/widgets_common/common_flushbar.dart';
import 'package:webblen/widgets_common/common_appbar.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/community.dart';
import 'package:flutter_tags/input_tags.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'package:flutter/services.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:flutter_picker/flutter_picker.dart';


class CreateEventPage extends StatefulWidget {

  final WebblenUser currentUser;
  final Community community;
  final bool isRecurring;
  CreateEventPage({this.currentUser, this.community, this.isRecurring});

  @override
  State<StatefulWidget> createState() {
    return _CreateEventPageState();
  }
}

class _CreateEventPageState extends State<CreateEventPage> {

  //Keys
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final searchScaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: Strings.googleAPIKEY);
  GlobalKey<FormState> page1FormKey;
  final page2FormKey = GlobalKey<FormState>();
  final page3FormKey = GlobalKey<FormState>();
  final page4FormKey = GlobalKey<FormState>();
  final page5FormKey = GlobalKey<FormState>();
  final page6FormKey = GlobalKey<FormState>();
  final page7FormKey = GlobalKey<FormState>();

  //Event
  Geoflutterfire geo = Geoflutterfire();
  double lat;
  double lon;
  Event newEvent = Event(radius: 0.25, fbSite: "", twitterSite: "", website: "");
  List<String> suggestedTags = [];
  List<String> selectedTags = [];
  File eventImage;
  bool showStartCalendar = false;
  bool showEndCalendar = false;
  String startDate = "";
  String endDate = "";
  String startTime = "";
  String endTime = "";
  int recurrenceRadioVal = 0;
  List<String> pageTitles = ['Event Details', 'Add Photo', 'Event Tags', 'Event Date', 'Event Time', 'External Links', 'Event Address'];
  int eventPageTitleIndex = 0;
  List<String> _inputTags = [];


  //Paging
  PageController _pageController;
  void nextPage() {
    setState(() {
      eventPageTitleIndex += 1;
    });
    _pageController.nextPage(duration: Duration(milliseconds: 600), curve: Curves.fastOutSlowIn);
  }
  void previousPage(){
    setState(() {
      eventPageTitleIndex -= 1;
    });
    _pageController.previousPage(duration: Duration(milliseconds: 600), curve: Curves.easeIn);
  }

  //Form Validations
  void validateSpecialEvent(){
    final form = page1FormKey.currentState;
    form.save();
    if (newEvent.title == null || newEvent.title.isEmpty) {
      AlertFlushbar(headerText: "Error", bodyText: "Event Title Cannot be Empty").showAlertFlushbar(context);
    } else if (newEvent.description == null || newEvent.description.isEmpty){
      AlertFlushbar(headerText: "Error", bodyText: "Event Description Cannot Be Empty").showAlertFlushbar(context);
    } else if (eventImage == null) {
      AlertFlushbar(headerText: "Error", bodyText: "Image is Required").showAlertFlushbar(context);
    } else if (newEvent.startDateInMilliseconds == null) {
      AlertFlushbar(headerText: "Error", bodyText: "Event Needs a Start Date").showAlertFlushbar(context);
    } else if (newEvent.endDateInMilliseconds == null) {
      AlertFlushbar(headerText: "Error", bodyText: "Event Needs an End Date").showAlertFlushbar(context);
    } else if (newEvent.fbSite != null || newEvent.twitterSite != null || newEvent.website != null) {
      bool urlIsValid = true;
      if (newEvent.fbSite.isNotEmpty){
        urlIsValid = OpenUrl().isValidUrl(newEvent.fbSite);
      }
      if (newEvent.twitterSite.isNotEmpty){
        urlIsValid = OpenUrl().isValidUrl(newEvent.twitterSite);
      }
      if (newEvent.website.isNotEmpty){
        urlIsValid = OpenUrl().isValidUrl(newEvent.website);
      }
      if (urlIsValid){
        nextPage();
      } else {
        AlertFlushbar(headerText: "URL Error", bodyText: "URL is Invalid").showAlertFlushbar(context);
      }
    } else {
      nextPage();
    }
  }

  void validateRegularEvent(){
    final form = page1FormKey.currentState;
    form.save();
    setState(() {
      newEvent.recurrence = getRadioValue();
    });
    if (newEvent.title == null || newEvent.title.isEmpty) {
      AlertFlushbar(headerText: "Error", bodyText: "Event Title Cannot be Empty").showAlertFlushbar(context);
    } else if (newEvent.description == null || newEvent.description.isEmpty){
      AlertFlushbar(headerText: "Error", bodyText: "Event Description Cannot Be Empty").showAlertFlushbar(context);
    } else if (eventImage == null) {
      AlertFlushbar(headerText: "Error", bodyText: "Image is Required").showAlertFlushbar(context);
    } else if (newEvent.fbSite != null || newEvent.twitterSite != null || newEvent.website != null) {
      bool urlIsValid = true;
      if (newEvent.fbSite.isNotEmpty){
        urlIsValid = OpenUrl().isValidUrl(newEvent.fbSite);
      }
      if (newEvent.twitterSite.isNotEmpty){
        urlIsValid = OpenUrl().isValidUrl(newEvent.twitterSite);
      }
      if (newEvent.website.isNotEmpty){
        urlIsValid = OpenUrl().isValidUrl(newEvent.website);
      }
      if (urlIsValid){
        nextPage();
      } else {
        AlertFlushbar(headerText: "URL Error", bodyText: "URL is Invalid").showAlertFlushbar(context);
      }
    } else {
      nextPage();
    }
  }

  void validateTags() {
    if (_inputTags == null || _inputTags.isEmpty){
      AlertFlushbar(headerText: "Event Tag Error", bodyText: "Event Needs At Least 1 Tag").showAlertFlushbar(context);
    } else {
      _inputTags.forEach((tag){
        _inputTags.remove(tag);
        tag = tag.replaceAll(RegExp(r"/^\s+|\s+$|\s+(?=\s)/g"), "");
        _inputTags.add(tag);
      });
      setState(() {
        newEvent.tags = _inputTags;
      });
      nextPage();
    }
  }


  void validateAndSubmit(){
    final form = page7FormKey.currentState;
    form.save();
    if (newEvent.address == null || newEvent.address.isEmpty){
      AlertFlushbar(headerText: "Address Error", bodyText: "Address Required").showAlertFlushbar(context);
    } else {
      ShowAlertDialogService().showLoadingDialog(context);
      if (newEvent.endDateInMilliseconds == null && newEvent.startDateInMilliseconds != null){
        DateTime eventStart = DateTime.fromMillisecondsSinceEpoch(newEvent.startDateInMilliseconds);
        newEvent.startDateInMilliseconds = eventStart.millisecondsSinceEpoch;
        newEvent.endDateInMilliseconds = eventStart.add(Duration(hours: 2)).millisecondsSinceEpoch;
      }
      newEvent.authorUid = widget.currentUser.uid;
      newEvent.attendees = [];
      newEvent.flashEvent = false;
      newEvent.eventPayout = 0.00;
      newEvent.estimatedTurnout = 0;
      newEvent.actualTurnout = 0;
      newEvent.pointsDistributedToUsers = false;
      newEvent.views = 0;
      newEvent.communityName = widget.community.name;
      newEvent.communityAreaName = widget.community.areaName;
      newEvent.tags = _inputTags;
      if (!widget.isRecurring) newEvent.recurrence = 'none';
      EventDataService().uploadEvent(eventImage, newEvent, lat, lon).then((error){
        if (error.isEmpty){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
          ShowAlertDialogService().showFailureDialog(context, 'Uh Oh', 'There was an issue uploading your event. Please try again.');
        }
      });
      //Navigator.push(context, ScaleRoute(widget: ConfirmEventPage(newEvent: newEventPost, newEventImage: eventImage)));
    }
  }


  void handleRadioValueChanged(int value) {
    setState(() {
      recurrenceRadioVal = value;
    });
  }

  String getRadioValue(){
    String val = 'daily';
    if (recurrenceRadioVal == 1){
      val = 'weekly';
    } else if (recurrenceRadioVal == 2) {
      val = 'monthly';
    }
    return val;
  }

  void setEventImage(bool getImageFromCamera) async {
    Navigator.of(context).pop();
    setState(() {
      eventImage = null;
    });
    eventImage = getImageFromCamera
        ? await WebblenImagePicker(context: context, ratioX: 1.0, ratioY: 1.0).retrieveImageFromCamera()
        : await WebblenImagePicker(context: context, ratioX: 1.0, ratioY: 1.0).retrieveImageFromLibrary();
    if (eventImage != null){
      setState(() {});
    }
  }


  void handleNewDate(DateTime selectedDate, bool isStartDate) {
    if (selectedDate.hour == 0 || selectedDate.hour == 12){
      selectedDate = selectedDate.add(Duration(hours: 12));
    }
    ScaffoldState scaffold = homeScaffoldKey.currentState;
    DateTime today = DateTime.now().subtract(Duration(hours: 1));
    if (selectedDate.isBefore(today)) {
      scaffold.showSnackBar(SnackBar(
        content: Text("Invalid Start Date"),
        backgroundColor: Colors.red,
        duration: Duration(milliseconds: 800),
      ));
    } else {
      if (isStartDate){
        setState(() {
          newEvent.startDateInMilliseconds = selectedDate.millisecondsSinceEpoch;
        });
      } else {
        if (selectedDate.millisecondsSinceEpoch < newEvent.startDateInMilliseconds){
          scaffold.showSnackBar(SnackBar(
            content: Text("Invalid End Date"),
            backgroundColor: Colors.red,
            duration: Duration(milliseconds: 800),
          ));
        } else {
          setState(() {
            newEvent.endDateInMilliseconds = selectedDate.millisecondsSinceEpoch;
          });
        }
      }
    }
  }

  showPickerDateTime(BuildContext context, String dateType) {
    Picker(
        adapter: new DateTimePickerAdapter(
          customColumnType: [1, 2, 0, 7, 4, 6],
          isNumberMonth: false,
          yearBegin: DateTime.now().year,
          yearEnd: DateTime.now().year + 6
        ),
        onConfirm: (Picker picker, List value) {
          DateTime selectedDate = (picker.adapter as DateTimePickerAdapter).value;
          if (dateType == 'start'){
            handleNewDate(selectedDate, true);
          } else {
            handleNewDate(selectedDate, false);
          }
        },
    ).show(homeScaffoldKey.currentState);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    page1FormKey = GlobalKey<FormState>();
    //suggestedTags = List<String>.from(widget.community.subtags);
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    DateFormat formatter = DateFormat('MMM dd, yyyy | h:mm a');

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
                     Fonts().textW500('1:1', 16.0, FlatColors.londonSquare, TextAlign.center)
                   ],
                )
              : Image.file(eventImage, fit: BoxFit.contain),
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
      );
    }

    Widget _buildStartDateField(){
      return Container(
          margin: EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
          child: GestureDetector(
            child: newEvent.startDateInMilliseconds == null
                ? Fonts().textW500("Start Date & Time", 18.0, FlatColors.londonSquare, TextAlign.left)
                : Fonts().textW500("${formatter.format(DateTime.fromMillisecondsSinceEpoch(newEvent.startDateInMilliseconds))}", 18.0, FlatColors.electronBlue, TextAlign.left),
            onTap: () => showPickerDateTime(context, 'start'),
          )
      );
    }

    Widget _buildEndDateField(){
      return newEvent.startDateInMilliseconds == null
        ? Container()
          : Container(
              margin:  EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: newEvent.endDateInMilliseconds == null
                      ? Fonts().textW500("End Date & Time", 18.0, FlatColors.londonSquare, TextAlign.left)
                      : Fonts().textW500("${formatter.format(DateTime.fromMillisecondsSinceEpoch(newEvent.endDateInMilliseconds))}", 18.0, FlatColors.electronBlue, TextAlign.left),
                    onTap: () => showPickerDateTime(context, 'end')
                  ),
                  newEvent.endDateInMilliseconds == null
                      ? Container()
                      : IconButton(
                          icon: Icon(FontAwesomeIcons.trash, color: Colors.black38, size: 14.0),
                            onPressed: (){
                              setState(() {
                                newEvent.endDateInMilliseconds = null;
                              });
                            }
                        ),
                ],
              ),
      );
    }

    Widget _buildRadioButtons() {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Fonts().textW500("daily", 16.0, FlatColors.darkGray, TextAlign.left),
                          Radio<int>(
                            value: 0,
                            groupValue: recurrenceRadioVal,
                            onChanged: handleRadioValueChanged,
                            activeColor: FlatColors.webblenRed,
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Fonts().textW500("weekly", 16.0, FlatColors.darkGray, TextAlign.left),
                          Radio<int>(
                            value: 1,
                            groupValue: recurrenceRadioVal,
                            onChanged: handleRadioValueChanged,
                            activeColor: FlatColors.webblenRed,
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Fonts().textW500("monthly", 16.0, FlatColors.darkGray, TextAlign.left),
                          Radio<int>(
                            value: 2,
                            groupValue: recurrenceRadioVal,
                            onChanged: handleRadioValueChanged,
                            activeColor: FlatColors.webblenRed,
                          )
                        ],
                      ),
                    ),
                  ]
              ),
            ]
        ),
      );
    }

    Widget _buildFBUrlField(){
      return Container(
        margin: EdgeInsets.only(left: 16.0, top: 4.0, right: 8.0),
        child: new TextFormField(
          initialValue: "",
          maxLines: 1,
          style: TextStyle(color: Colors.black, fontSize: 16.0, fontFamily: 'Barlow', fontWeight: FontWeight.w500),
          autofocus: false,
          onSaved: (url) {
            if (!url.contains('http://') || !url.contains('https://')) {
              if (!url.contains('www.')){
                url = 'http://www.' + url;
              } else {
                url = 'http://' + url;
              }
            }
            newEvent.fbSite = url;
          },
          inputFormatters: [
            BlacklistingTextInputFormatter(RegExp("[\\ |\\,]"))
          ],
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            icon: Icon(FontAwesomeIcons.facebook, color: FlatColors.darkGray, size: 18),
            border: InputBorder.none,
            hintText: "Facebook Page URL",
            counterStyle: TextStyle(fontFamily: 'Helvetica Neue'),
            contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
          ),
        ),
      );
    }

    Widget _buildTwitterUrlField(){
      return Container(
        margin: EdgeInsets.only(left: 16.0, top: 4.0, right: 8.0),
        child: new TextFormField(
          initialValue: "",
          maxLines: 1,
          style: TextStyle(color: Colors.black, fontSize: 16.0, fontFamily: 'Barlow', fontWeight: FontWeight.w500),
          autofocus: false,
          inputFormatters: [
            BlacklistingTextInputFormatter(RegExp("[\\#|\\[|\\]|\\%|\\^|\\*|\\+|\\=|\\_|\\~|\\<|\\>|\\,|\\(|\\)|\\'|\\{|\\}]"))
          ],
          onSaved: (value) {
            if (value != null && value.isNotEmpty){
              newEvent.twitterSite = 'https://www.twitter.com/' + value;
              setState(() {});
            }
          },
          decoration: InputDecoration(
            icon: Icon(FontAwesomeIcons.twitter, color: FlatColors.darkGray, size: 18),
            border: InputBorder.none,
            hintText: "@twitter_handle",
            counterStyle: TextStyle(fontFamily: 'Helvetica Neue'),
            contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
          ),
        ),
      );
    }

    Widget _buildWebsiteUrlField(){
      return Container(
        margin: EdgeInsets.only(left: 16.0, top: 4.0, right: 8.0),
        child: new TextFormField(
          initialValue: "",
          maxLines: 1,
          style: TextStyle(color: Colors.black, fontSize: 16.0, fontFamily: 'Barlow', fontWeight: FontWeight.w500),
          autofocus: false,
          inputFormatters: [
            BlacklistingTextInputFormatter(RegExp("[\\ |\\,]"))
          ],
          onSaved: (url) {
            if (!url.contains('http://') || !url.contains('https://')) {
              if (!url.contains('www.')){
                url = 'http://www.' + url;
              } else {
                url = 'http://' + url;
              }
            }
            newEvent.website = url;
          },
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            icon: Icon(FontAwesomeIcons.globe, color: FlatColors.darkGray, size: 18),
            border: InputBorder.none,
            hintText: "Website URL",
            counterStyle: TextStyle(fontFamily: 'Helvetica Neue'),
            contentPadding: EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 10.0),
          ),
        ),
      );
    }

    Widget _buildSearchAutoComplete(){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Fonts().textW500(
              newEvent.address == null || newEvent.address.isEmpty
                  ? "Set Address"
                  : "${newEvent.address}",
              16.0,
              FlatColors.darkGray,
              TextAlign.center),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                  color: Colors.white70,
                  onPressed: () async {
                    Prediction p = await PlacesAutocomplete.show(
                        context: context,
                        apiKey: Strings.googleAPIKEY,
                        onError: (res) {
                          homeScaffoldKey.currentState.showSnackBar(
                              SnackBar(content: Text(res.errorMessage)));
                        },
                        mode: Mode.overlay,
                        language: "en",
                        components: [Component(Component.country, "us")]);
                    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
                    setState(() {
                      lat = detail.result.geometry.location.lat;
                      lon = detail.result.geometry.location.lng;
                      newEvent.address = p.description.replaceAll(', USA', '');
                    });
//              displayPrediction(p, homeScaffoldKey.currentState);
                  },
                  child: Text("Search Address")
              ),
              RaisedButton(
                  color: Colors.white70,
                  onPressed: () async {
                    LocationService().getCurrentLocation(context).then((location){
                      if (this.mounted){
                        if (location == null){
                          ShowAlertDialogService().showFailureDialog(context, 'Cannot Retrieve Location', 'Location Permission Disabled');
                        } else {
                          var currentLocation = location;
                          lat = currentLocation.latitude;
                          lon = currentLocation.longitude;
                          LocationService().getAddressFromLatLon(lat, lon).then((foundAddress){
                            newEvent.address = foundAddress.replaceAll(', USA', '');
                            setState(() {});
                          });
                        }
                      }
                    });
                  },
                  child: Text("Current Location")
              ),
            ],
          ),
        ],
      );
    }

    Widget _buildDistanceSlider(){
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        child: Slider(
          activeColor: FlatColors.webblenRed,
          value: newEvent.radius,
          min: 0.25,
          max: 10.0,
          divisions: 39,
          onChanged: (double value) {
            setState(() {
              newEvent.radius = value;
            });
          },
        ),
      );
    }


    //Form Buttons
    final formButton1 = NewEventFormButton("Next", FlatColors.blackPearl, Colors.white, widget.isRecurring ? this.validateRegularEvent: this.validateSpecialEvent);
    final formButton2 = NewEventFormButton("Next", FlatColors.blackPearl, Colors.white, this.validateTags);
    final submitButton = NewEventFormButton("Submit", FlatColors.blackPearl, Colors.white, this.validateAndSubmit);
    final backButton = FlatBackButton("Back", FlatColors.blackPearl, Colors.white, this.previousPage);

    //**Title, Description, Dates, URLS
    final eventFormPage1 = Container(
      color: Colors.white,
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
                  child: widget.isRecurring ? Fonts().textW700("Frequency", 18.0, FlatColors.darkGray, TextAlign.left) : Fonts().textW700("Date", 18.0, FlatColors.darkGray, TextAlign.left),
                ),
                widget.isRecurring ? _buildRadioButtons() : _buildStartDateField() ,
                widget.isRecurring ? Container() : _buildEndDateField(),
                Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 24.0, right: 16.0),
                  child: Fonts().textW700("External Links (Optional)", 18.0, FlatColors.darkGray, TextAlign.left),
                ),
                _buildFBUrlField(),
                _buildTwitterUrlField(),
                _buildWebsiteUrlField(),
                formButton1
              ],
            ),
          )
      ),
    );

    //**Tags Page
    final eventFormPage2 = Container(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Container(
            child:
            InputTags(
              tags: _inputTags,
              iconBackground: FlatColors.darkGray,
              color: Colors.white,
              textStyle: TextStyle(color: FlatColors.darkGray, fontWeight: FontWeight.w500, fontFamily: 'Barlow'),
              lowerCase: true,
              autofocus: false,
              popupMenuBuilder: (String tag){
                return <PopupMenuEntry>[
                  PopupMenuItem(
                    child: Text(tag,
                      style: TextStyle(
                          color: Colors.black87,fontWeight: FontWeight.w800
                      ),
                    ),
                    enabled: false,
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.content_copy,size: 18,),
                        Text(" Copy text"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.delete,size: 18),
                        Text(" Remove"),
                      ],
                    ),
                  )
                ];
              },
              popupMenuOnSelected: (int id,String tag){
                switch(id){
                  case 1:
                    Clipboard.setData( ClipboardData(text: tag));
                    break;
                  case 2:
                    setState(() {
                      _inputTags.remove(tag);
                    });
                }
              },
              height: 40,
              textFieldHidden: _inputTags.length >= 6 ? true : false,
              backgroundContainer: Colors.transparent,
              onDelete: (tag) {
                setState(() {
                  _inputTags.remove(tag);
                });
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          formButton2,
          backButton
        ],
      )
    );


    //**Address Page
    final eventFormPage3 = Container(
      child: ListView(
        children: <Widget>[
          Form(
            key: page7FormKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.13),
                _buildSearchAutoComplete(),
                SizedBox(height: 32.0),
                Row(
                  children: <Widget>[
                    SizedBox(width: 16.0),
                    Fonts().textW500('Notify Users Within: ', 16.0, FlatColors.darkGray, TextAlign.left),
                    Fonts().textW400('${(newEvent.radius.toStringAsFixed(2))} Miles ', 16.0, FlatColors.darkGray, TextAlign.left),
                  ],
                ),
                _buildDistanceSlider(),
                SizedBox(height: 32.0),
                Row(
                  children: <Widget>[
                    SizedBox(width: 16.0),
                    Fonts().textW700('Estimated Reach: ', 16.0, FlatColors.darkGray, TextAlign.left),
                    Fonts().textW400('${(newEvent.radius.round() * 13)}', 16.0, FlatColors.darkGray, TextAlign.left),
                  ],
                ),
                SizedBox(height: 4.0),
                Row(
                  children: <Widget>[
                    SizedBox(width: 16.0),
                    Fonts().textW700('Total Cost: ', 16.0, FlatColors.darkGray, TextAlign.left),
                    Fonts().textW400('FREE', 16.0, FlatColors.darkGray, TextAlign.left),
                  ],
                ),
                SizedBox(height: 30.0),
                submitButton,
                backButton,
              ],
            ),
          )
        ],
      ),
    );

    return Scaffold(
      appBar: WebblenAppBar().newEventAppBar(context, 'New Event', 'Cancel Adding a New Event?', (){
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }),
      key: homeScaffoldKey,
      body: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                eventFormPage1,
                eventFormPage2,
                eventFormPage3
              ]
          ),
      ),
    );
  }

}
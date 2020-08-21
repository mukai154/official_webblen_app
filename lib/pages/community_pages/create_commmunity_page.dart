import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/constants/strings.dart';
import 'package:webblen/constants/timezones.dart';
import 'package:webblen/firebase/data/event_data.dart';
import 'package:webblen/firebase/data/user_data.dart';
import 'package:webblen/firebase_data/auth.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/ticket_distro.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/location/location_service.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:webblen/widgets/common/alerts/custom_alerts.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/buttons/custom_color_button.dart';
import 'package:webblen/widgets/common/containers/text_field_container.dart';
import 'package:webblen/widgets/common/state/progress_indicator.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';

class CreateCommunityPage extends StatefulWidget {
  final String comID;
  CreateCommunityPage({this.comID});

  @override
  _CreateCommunityPageState createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  String currentUID;
  bool isLoading = true;
  bool isTypingMultiLine = false;
  TextEditingController controller = TextEditingController();
  GlobalKey formKey = GlobalKey<FormState>();
  //Event Details
  WebblenCommunity community;
  String comName;
  String eventDesc;
  String eventImgURL;
  String eventChatID;
  //Location Details
  bool isDigitalEvent = false;
  String venueName;
  double lat;
  double lon;
  String eventAddress;
  String address1;
  String address2;
  String city;
  String province = "AL";
  String zipPostalCode;
  String digitalEventLink;
  List nearbyZipcodes = [];
  List sharedComs = [];
  List tags = [];
  int eventClicks = 0;
  String webAppLink;

  //Date & Time Details
  DateTime selectedDateTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    DateTime.now().hour,
  );

  DateFormat dateFormatter = DateFormat('MMM dd, yyyy');
  DateFormat timeFormatter = DateFormat('h:mm a');
  int startDateTimeInMilliseconds;
  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();
  String startDate;
  String endDate;
  String startTime;
  String endTime;
  String timezone = "CDT";
  // Event Image
  File eventImgFile;

  //Ticketing
  TicketDistro ticketDistro = TicketDistro(tickets: [], fees: [], discountCodes: [], usedTicketIDs: [], validTicketIDs: []);
  GlobalKey ticketFormKey = GlobalKey<FormState>();
  GlobalKey feeFormKey = GlobalKey<FormState>();
  GlobalKey discountFormKey = GlobalKey<FormState>();
  MoneyMaskedTextController moneyMaskedTextController = MoneyMaskedTextController(
    leftSymbol: "\$",
    precision: 2,
    decimalSeparator: '.',
    thousandSeparator: ',',
  );
  bool showTicketForm = false;
  bool showFeeForm = false;
  bool showDiscountCodeForm = false;
  String ticketName;
  String ticketPrice;
  String ticketQuantity;
  String feeName;
  String feeAmount;
  String discountCodeName;
  String discountCodeQuantity;
  String discountCodePercentage;

  //Additional Info & Social Links
  String privacy = 'public';
  List<String> privacyOptions = ['public', 'private'];
  String eventType = 'Select Event Type';
  String eventCategory = 'Select Event Category';
  String fbUsername;
  String twitterUsername;
  String instaUsername;
  String websiteURL;

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
    eventAddress = detail.result.formattedAddress;
    lat = detail.result.geometry.location.lat;
    lon = detail.result.geometry.location.lng;
    CustomAlerts().showLoadingAlert(context, "Setting Location...");
    Map<String, dynamic> locationData = await LocationService().reverseGeocodeLatLon(lat, lon);
    Navigator.of(context).pop();
    zipPostalCode = locationData['zipcode'];
    city = locationData['city'];
    province = locationData['administrativeLevels']['level1short'];
    lat = detail.result.geometry.location.lat;
    lon = detail.result.geometry.location.lng;
  }

  Widget addImageButton() {
    return GestureDetector(
      onTap: () {
        dismissKeyboard();
        ShowAlertDialogService().showImageSelectDialog(
          context,
          () => setEventImage(true),
          () => setEventImage(false),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.black12,
        ),
        child: widget.eventID != null
            ? eventImgFile == null
                ? CachedNetworkImage(
                    imageUrl: eventImgURL,
                    fit: BoxFit.contain,
                  )
                : Image.file(
                    eventImgFile,
                    fit: BoxFit.contain,
                  )
            : eventImgFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.camera_alt,
                        size: 40.0,
                        color: CustomColors.londonSquare,
                      ),
                      CustomText(
                        context: context,
                        text: '1:1',
                        textColor: CustomColors.londonSquare,
                        textAlign: TextAlign.left,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ],
                  )
                : Image.file(
                    eventImgFile,
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

  Widget eventTitleField() {
    return TextFieldContainer(
      child: TextFormField(
        onTap: () {},
        initialValue: eventTitle,
        cursorColor: Colors.black,
        validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
        onChanged: (value) {
          setState(() {
            eventTitle = value.trim();
          });
        },
        onSaved: (value) => eventTitle = value.trim(),
        inputFormatters: [
          LengthLimitingTextInputFormatter(75),
        ],
        decoration: InputDecoration(
          hintText: "Name of the Event",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget isDigitalEventCheckBox() {
    return Row(
      children: <Widget>[
        CustomText(
          context: context,
          text: "This is a Digital/Online Event",
          textColor: Colors.black,
          textAlign: TextAlign.left,
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
        Checkbox(
          activeColor: CustomColors.webblenRed,
          value: isDigitalEvent,
          onChanged: (val) {
            isDigitalEvent = val;
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget eventVenueNameField() {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: venueName,
        cursorColor: Colors.black,
        onChanged: (value) {
          setState(() {
            venueName = value.trim();
          });
        },
        inputFormatters: [
          LengthLimitingTextInputFormatter(75),
        ],
        decoration: InputDecoration(
          hintText: "Venue Name",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget eventLocationField() {
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
                text: eventAddress == null || eventAddress.isEmpty ? "Search for Address" : eventAddress,
                textColor: eventAddress == null || eventAddress.isEmpty ? Colors.black54 : Colors.black,
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

  Widget eventDigitalLinkField() {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: digitalEventLink,
        cursorColor: Colors.black,
        onChanged: (value) {
          setState(() {
            digitalEventLink = value.trim();
          });
        },
        inputFormatters: [
          LengthLimitingTextInputFormatter(75),
        ],
        decoration: InputDecoration(
          hintText: "Event Link",
          border: InputBorder.none,
        ),
      ),
    );
  }

  openCalendar(bool isStartDate) {
    Alert(
      context: context,
      title: isStartDate ? "Start Date" : "End Date",
      content: Container(
        child: CalendarCarousel(
          isScrollable: false,
          width: 300,
          height: 320,
          headerTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
          ),
          iconColor: Colors.black,
          todayButtonColor: CustomColors.webblenRedLowOpacity,
          weekdayTextStyle: TextStyle(color: Colors.black),
          weekendTextStyle: TextStyle(color: CustomColors.webblenRed),
          minSelectedDate: isStartDate ? DateTime.now() : selectedStartDate,
          onDayPressed: (DateTime date, List<Event> events) {
            if (isStartDate) {
              selectedStartDate = date;
              startDate = dateFormatter.format(date);
              if (selectedStartDate.isAfter(selectedEndDate)) {
                selectedEndDate = date;
                endDate = dateFormatter.format(date);
              }
            } else {
              selectedEndDate = date;
              endDate = dateFormatter.format(date);
            }
            setState(() {});
            Navigator.of(context).pop();
          },
        ),
      ),
      buttons: [
        DialogButton(
          color: CustomColors.textFieldGray,
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          onPressed: () => Navigator.pop(context),
          width: 150,
        ),
      ],
    ).show();
  }

  Widget eventTimeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        fieldHeader("Starts", true),
        Row(
          children: <Widget>[
            GestureDetector(
              onTap: () => openCalendar(true),
              child: TextFieldContainer(
                width: 200,
                child: Padding(
                  padding: EdgeInsets.only(top: 16.0, right: 8.0, bottom: 16.0),
                  child: CustomText(
                    context: context,
                    text: startDate,
                    textColor: Colors.black,
                    textAlign: TextAlign.left,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.0),
            TextFieldContainer(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                ),
                child: DropdownButton(
                    isDense: true,
                    underline: Container(),
                    value: startTime,
                    items: Strings.timeList.map((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: (val) {
                      startTime = val;
                      DateTime formattedStartTime = timeFormatter.parse(startTime);
                      DateTime formattedEndTime = timeFormatter.parse(endTime);
                      if (formattedStartTime.isAfter(formattedEndTime)) {
                        endTime = startTime;
                      }
                      setState(() {});
                    }),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.0),
        fieldHeader("Ends", true),
        Row(
          children: <Widget>[
            GestureDetector(
              onTap: () => openCalendar(false),
              child: TextFieldContainer(
                width: 200,
                child: Padding(
                  padding: EdgeInsets.only(top: 16.0, right: 8.0, bottom: 16.0),
                  child: CustomText(
                    context: context,
                    text: endDate,
                    textColor: Colors.black,
                    textAlign: TextAlign.left,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.0),
            TextFieldContainer(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 12,
                ),
                child: DropdownButton(
                    isDense: true,
                    underline: Container(),
                    value: endTime,
                    items: startDate == endDate
                        ? Strings().timeListFromSelectedTime(startTime).map((String val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(val),
                            );
                          }).toList()
                        : Strings.timeList.map((String val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(val),
                            );
                          }).toList(),
                    onChanged: (val) {
                      setState(() {
                        endTime = val;
                      });
                    }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget eventTimezoneField() {
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            fieldHeader("Timezone", true),
            Row(
              children: <Widget>[
                DropdownButton(
                    icon: Container(),
                    underline: Container(),
                    value: timezone,
                    items: Timezones.timezones.map((Map<String, dynamic> item) {
                      return DropdownMenuItem<String>(
                        value: item['abbr'],
                        child: Container(
                          width: MediaQuery.of(context).size.width - 32.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              CustomText(
                                context: context,
                                text: "${item['value']}: ${item['abbr']}",
                                textColor: item['abbr'] == timezone ? Colors.blue : Colors.black,
                                textAlign: TextAlign.left,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w700,
                              ),
                              CustomText(
                                context: context,
                                text: item['text'],
                                textColor: item['abbr'] == timezone ? Colors.blue : Colors.black,
                                textAlign: TextAlign.left,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      print(val);
                      setState(() {
                        timezone = val;
                      });
                    }),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget eventImgButton() {
    return eventImgFile == null && eventImgURL == null
        ? Row(
            children: <Widget>[
              GestureDetector(
                onTap: null, //() => setEventImage(getImageFromCamera),
                child: Container(
                  height: 250,
                  width: 250,
                  color: CustomColors.textFieldGray,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.camera_alt,
                        size: 40.0,
                        color: Colors.black26,
                      ),
                      CustomText(
                        context: context,
                        text: "1:1",
                        textColor: Colors.black26,
                        textAlign: TextAlign.left,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : eventImgFile != null
            ? Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: null, //() => uploadImage(),
                    child: Container(
                      height: 250,
                      width: 250,
                      child: Image.file(eventImgFile),
                    ),
                  )
                ],
              )
            : Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: null, //() => uploadImage(),
                    child: Container(
                      height: 250,
                      width: 250,
                      child: Image.network(eventImgURL),
                    ),
                  )
                ],
              );
  }

  void setEventImage(bool getImageFromCamera) async {
    Navigator.of(context).pop();
    setState(() {
      eventImgFile = null;
    });
    eventImgFile = getImageFromCamera
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
    if (eventImgFile != null) {
      setState(() {});
    }
  }

  Widget eventDescriptionField() {
    return TextFieldContainer(
      child: TextFormField(
        onTap: () {
          isTypingMultiLine = true;
          setState(() {});
        },
        initialValue: eventDesc,
        cursorColor: Colors.black,
        validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
        maxLines: null,
        onChanged: (value) {
          setState(() {
            eventDesc = value.trim();
          });
        },
        decoration: InputDecoration(
          hintText: "Event Information and Details",
          border: InputBorder.none,
        ),
      ),
    );
  }

  //EVENT TICKETING
  Widget ticketingFormHeader(String formType) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: CustomColors.textFieldGray,
        border: Border.all(
          width: 1.0,
          color: Colors.black26,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 175,
            child: CustomText(
              context: context,
              text: formType == "ticket" ? "Ticket Name" : formType == "fee" ? "Fee Name" : "Discount Code Name",
              textColor: Colors.black,
              textAlign: TextAlign.left,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          formType == "ticket" || formType == "discountCode"
              ? Container(
                  width: 70,
                  child: CustomText(
                    context: context,
                    text: formType == "ticket" ? "Qty Available" : "Limit",
                    textColor: Colors.black,
                    textAlign: TextAlign.left,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : Container(
                  width: 70,
                  child: CustomText(
                    context: context,
                    text: "Amount",
                    textColor: Colors.black,
                    textAlign: TextAlign.left,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          formType == "ticket" || formType == "discountCode"
              ? Container(
                  width: 70,
                  child: CustomText(
                    context: context,
                    text: formType == "ticket" ? "Price" : "Percent Off",
                    textColor: Colors.black,
                    textAlign: TextAlign.left,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : Container(width: 70),
          Container(width: 35),
        ],
      ),
    );
  }

  Widget ticketListBuilder() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: ticketDistro.tickets.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 175,
                    child: CustomText(
                      context: context,
                      text: ticketDistro.tickets[index]["ticketName"],
                      textColor: Colors.black,
                      textAlign: TextAlign.left,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 70,
                    child: CustomText(
                      context: context,
                      text: ticketDistro.tickets[index]["ticketQuantity"],
                      textColor: Colors.black,
                      textAlign: TextAlign.left,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 70.0,
                    child: CustomText(
                      context: context,
                      text: ticketDistro.tickets[index]["ticketPrice"],
                      textColor: Colors.black,
                      textAlign: TextAlign.left,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  showTicketForm
                      ? Container(width: 35.0)
                      : Container(
                          width: 35.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () => editAction('ticket', index),
                                child: Icon(FontAwesomeIcons.edit, size: 16.0, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            );
          }),
    );
  }

  Widget feeListBuilder() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: ticketDistro.fees.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 175,
                    child: CustomText(
                      context: context,
                      text: ticketDistro.fees[index]["feeName"],
                      textColor: Colors.black,
                      textAlign: TextAlign.left,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 70,
                    child: CustomText(
                      context: context,
                      text: ticketDistro.fees[index]["feeAmount"],
                      textColor: Colors.black,
                      textAlign: TextAlign.left,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 70,
                  ),
                  showTicketForm
                      ? Container(width: 40)
                      : Container(
                          width: 35.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () => editAction('fee', index),
                                child: Icon(FontAwesomeIcons.edit, size: 16.0, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            );
          }),
    );
  }

  Widget discountListBuilder() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: ticketDistro.discountCodes.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 175,
                    child: CustomText(
                      context: context,
                      text: ticketDistro.discountCodes[index]["discountCodeName"],
                      textColor: Colors.black,
                      textAlign: TextAlign.left,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 70,
                    child: CustomText(
                      context: context,
                      text: ticketDistro.discountCodes[index]["discountCodeQuantity"],
                      textColor: Colors.black,
                      textAlign: TextAlign.left,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    width: 70,
                    child: CustomText(
                      context: context,
                      text: ticketDistro.discountCodes[index]["discountCodePercentage"],
                      textColor: Colors.black,
                      textAlign: TextAlign.left,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  showTicketForm
                      ? Container(width: 35)
                      : Container(
                          width: 35,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () => editAction('discountCode', index),
                                child: Icon(FontAwesomeIcons.edit, size: 16.0, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            );
          }),
    );
  }

  Widget ticketForm() {
    return Form(
      key: ticketFormKey,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextFieldContainer(
                  width: 175,
                  child: TextFormField(
                    onTap: () {
                      isTypingMultiLine = false;
                      setState(() {});
                    },
                    initialValue: ticketName,
                    cursorColor: Colors.black,
                    validator: (value) => value.isEmpty ? 'Empty' : null,
                    onSaved: (value) => ticketName = value.trim(),
                    decoration: InputDecoration(
                      hintText: "General Admission",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  width: 70,
                  child: TextFormField(
                    onTap: () {
                      isTypingMultiLine = false;
                      setState(() {});
                    },
                    initialValue: ticketQuantity,
                    cursorColor: Colors.black,
                    validator: (value) => value.isEmpty ? 'Empty' : null,
                    onSaved: (value) => ticketQuantity = value.trim(),
                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: "100",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  width: 70,
                  child: TextFormField(
                    onTap: () {
                      isTypingMultiLine = false;
                      setState(() {});
                    },
                    controller: moneyMaskedTextController,
                    cursorColor: Colors.black,
                    validator: (value) => value.isEmpty ? 'Empty' : null,
                    onSaved: (value) => ticketPrice = value.trim(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(width: 35.0),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CustomColorButton(
                  text: "Create Ticket",
                  textColor: Colors.white,
                  backgroundColor: CustomColors.darkMountainGreen,
                  height: 35.0,
                  width: 140,
                  onPressed: () => validateTicketForm(),
                ),
                SizedBox(width: 16.0),
                CustomColorButton(
                  text: "Delete",
                  textColor: Colors.white,
                  backgroundColor: CustomColors.webblenRed,
                  height: 35.0,
                  width: 100,
                  onPressed: () => changeFormStatus("ticketForm"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget feeForm() {
    return Form(
      key: feeFormKey,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextFieldContainer(
                  width: 175,
                  child: TextFormField(
                    onTap: () {
                      isTypingMultiLine = false;
                      setState(() {});
                    },
                    initialValue: feeName,
                    cursorColor: Colors.black,
                    validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
                    onSaved: (value) => feeName = value.trim(),
                    decoration: InputDecoration(
                      hintText: "Venue Fee",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  width: 70,
                  child: TextFormField(
                    onTap: () {
                      isTypingMultiLine = false;
                      setState(() {});
                    },
                    controller: moneyMaskedTextController,
                    cursorColor: Colors.black,
                    validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
                    onSaved: (value) => feeAmount = value.trim(),
                    decoration: InputDecoration(
                      hintText: "\$9.99",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(width: 70),
                Container(
                  width: 40,
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CustomColorButton(
                  text: "Create Fee",
                  textColor: Colors.white,
                  backgroundColor: CustomColors.darkMountainGreen,
                  height: 35.0,
                  width: 140,
                  onPressed: () => validateFeeForm(),
                ),
                SizedBox(width: 16.0),
                CustomColorButton(
                  text: "Delete",
                  textColor: Colors.white,
                  backgroundColor: CustomColors.webblenRed,
                  height: 35.0,
                  width: 100,
                  onPressed: () => changeFormStatus("feeForm"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget discountCodeForm() {
    return Form(
      key: discountFormKey,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextFieldContainer(
                  width: 175,
                  child: TextFormField(
                    onTap: () {
                      isTypingMultiLine = false;
                      setState(() {});
                    },
                    initialValue: discountCodeName,
                    cursorColor: Colors.black,
                    validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
                    onSaved: (value) => discountCodeName = value.trim(),
                    decoration: InputDecoration(
                      hintText: "Discount Code",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  width: 70,
                  child: TextFormField(
                    onTap: () {
                      isTypingMultiLine = false;
                      setState(() {});
                    },
                    cursorColor: Colors.black,
                    validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
                    onSaved: (value) => discountCodeQuantity = value.trim(),
                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: "100",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  width: 70,
                  child: TextFormField(
                    onTap: () {
                      isTypingMultiLine = false;
                      setState(() {});
                    },
                    initialValue: discountCodePercentage,
                    cursorColor: Colors.black,
                    validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
                    onSaved: (value) {
                      int x = int.parse(value);
                      if (x > 100) {
                        discountCodePercentage = "100";
                      } else {
                        discountCodePercentage = value.trim();
                      }
                    },
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: InputDecoration(
                      hintText: "100",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CustomColorButton(
                  text: "Create Discount",
                  textColor: Colors.white,
                  backgroundColor: CustomColors.darkMountainGreen,
                  height: 35.0,
                  width: 140,
                  onPressed: () => validateDiscountCodeForm(),
                ),
                SizedBox(width: 16.0),
                CustomColorButton(
                  text: "Delete",
                  textColor: Colors.white,
                  backgroundColor: Colors.red,
                  height: 35.0,
                  width: 100,
                  onPressed: () => changeFormStatus("discountCodeForm"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  editAction(String object, int objectIndex) {
    if (object == "ticket") {
      ticketName = ticketDistro.tickets[objectIndex]['ticketName'];
      ticketQuantity = ticketDistro.tickets[objectIndex]['ticketQuantity'];
      ticketPrice = ticketDistro.tickets[objectIndex]['ticketPrice'];
      ticketDistro.tickets.removeAt(objectIndex);
      changeFormStatus("ticketForm");
    } else if (object == "fee") {
      feeName = ticketDistro.fees[objectIndex]['feeName'];
      feeAmount = ticketDistro.fees[objectIndex]['feeAmount'];
      ticketDistro.fees.removeAt(objectIndex);
      changeFormStatus("feeForm");
    } else {
      discountCodeName = ticketDistro.discountCodes[objectIndex]['discountCodeName'];
      discountCodeQuantity = ticketDistro.discountCodes[objectIndex]['discountCodeQuantity'];
      discountCodePercentage = ticketDistro.discountCodes[objectIndex]['discountCodePercentage'];
      ticketDistro.discountCodes.removeAt(objectIndex);
      changeFormStatus("discountCodeForm");
    }
  }

  deleteAction(String object, int objectIndex) {
    if (object == "ticket") {
      ticketDistro.tickets.removeAt(objectIndex);
    } else if (object == "fee") {
      ticketDistro.fees.removeAt(objectIndex);
    } else {
      ticketDistro.discountCodes.removeAt(objectIndex);
    }
    setState(() {});
  }

  Widget ticketActions() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          CustomColorButton(
            text: "Add Ticket",
            textColor: Colors.black,
            backgroundColor: Colors.white,
            height: 35.0,
            onPressed: () => changeFormStatus("ticketForm"),
          ),
          SizedBox(height: 8.0),
          ticketDistro.tickets.length > 0
              ? CustomColorButton(
                  text: "Add Fee",
                  textColor: Colors.black,
                  backgroundColor: Colors.white,
                  height: 35.0,
                  onPressed: () => changeFormStatus("feeForm"),
                )
              : Container(),
          SizedBox(height: 8.0),
          ticketDistro.tickets.length > 0
              ? CustomColorButton(
                  text: "Add Discount Code",
                  textColor: Colors.black,
                  backgroundColor: Colors.white,
                  height: 35.0,
                  onPressed: () => changeFormStatus("discountCodeForm"),
                )
              : Container(),
        ],
      ),
    );
  }

  changeFormStatus(String form) {
    if (form == "ticketForm") {
      print('ticketForm');
      if (showTicketForm) {
        showTicketForm = false;
      } else {
        showTicketForm = true;
      }
    } else if (form == "feeForm") {
      if (showFeeForm) {
        showFeeForm = false;
      } else {
        showFeeForm = true;
      }
    } else {
      if (showDiscountCodeForm) {
        showDiscountCodeForm = false;
      } else {
        showDiscountCodeForm = true;
      }
    }
    setState(() {});
  }

  void validateTicketForm() {
    FormState ticketFormState = ticketFormKey.currentState;
    bool formIsValid = ticketFormState.validate();
    if (formIsValid) {
      ticketFormState.save();
      Map<String, dynamic> eventTicket = {
        "ticketName": ticketName,
        "ticketPrice": ticketPrice,
        "ticketQuantity": ticketQuantity,
      };
      ticketDistro.tickets.add(eventTicket);
      ticketName = null;
      ticketPrice = null;
      ticketQuantity = null;
      changeFormStatus("ticketForm");
      setState(() {});
    }
  }

  void validateFeeForm() {
    FormState feeFormState = feeFormKey.currentState;
    bool formIsValid = feeFormState.validate();
    if (formIsValid) {
      feeFormState.save();
      Map<String, dynamic> eventFee = {
        "feeName": feeName,
        "feeAmount": feeAmount,
      };
      ticketDistro.fees.add(eventFee);
      feeName = null;
      feeAmount = null;
      changeFormStatus("feeForm");
      setState(() {});
    }
  }

  void validateDiscountCodeForm() {
    FormState feeFormState = discountFormKey.currentState;
    bool formIsValid = feeFormState.validate();
    if (formIsValid) {
      feeFormState.save();
      Map<String, dynamic> discountCode = {
        "discountCodeName": discountCodeName,
        "discountCodeQuantity": discountCodeQuantity,
        "discountCodePercentage": discountCodePercentage,
      };
      ticketDistro.discountCodes.add(discountCode);
      discountCodeName = null;
      discountCodeQuantity = null;
      discountCodePercentage = null;
      changeFormStatus("discountCodeForm");
      setState(() {});
    }
  }

  //ADDITIONAL INFO & SOCIAL LINKS
  Widget eventPrivacyDropdown() {
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
                value: privacy,
                items: privacyOptions.map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    privacy = val;
                  });
                }),
          ),
        ),
      ],
    );
  }

  Widget eventCategoryDropDown() {
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
                value: eventCategory,
                items: Strings.eventCategories.map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    eventCategory = val;
                  });
                }),
          ),
        ),
      ],
    );
  }

  Widget eventTypeDropDown() {
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
                value: eventType,
                items: Strings.eventTypes.map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    eventType = val;
                  });
                }),
          ),
        ),
      ],
    );
  }

  Widget fbSocialHeader() {
    return Row(
      children: <Widget>[
        Icon(FontAwesomeIcons.facebook, size: 16.0, color: Colors.black),
        SizedBox(width: 4.0),
        CustomText(
          context: context,
          text: "facebook.com/",
          textColor: Colors.black,
          textAlign: TextAlign.left,
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }

  Widget fbUsernameField() {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: fbUsername,
        cursorColor: Colors.black,
        onSaved: (value) {
          setState(() {
            fbUsername = value.trim();
          });
        },
        decoration: InputDecoration(
          hintText: "FB Profile/Page Username",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget instaSocialHeader() {
    return Row(
      children: <Widget>[
        Icon(FontAwesomeIcons.instagram, size: 16.0, color: Colors.black),
        SizedBox(width: 4.0),
        CustomText(
          context: context,
          text: "instagram.com/",
          textColor: Colors.black,
          textAlign: TextAlign.left,
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }

  Widget instaUsernameField() {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: instaUsername,
        cursorColor: Colors.black,
        onSaved: (value) {
          setState(() {
            instaUsername = value.trim();
          });
        },
        decoration: InputDecoration(
          hintText: "Insta Username",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget twitterSocialHeader() {
    return Row(
      children: <Widget>[
        Icon(FontAwesomeIcons.twitter, size: 16.0, color: Colors.black),
        SizedBox(width: 4.0),
        CustomText(
          context: context,
          text: "twitter.com/",
          textColor: Colors.black,
          textAlign: TextAlign.left,
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }

  Widget twitterUsernameField() {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: twitterUsername,
        cursorColor: Colors.black,
        onSaved: (value) {
          setState(() {
            twitterUsername = value.trim();
          });
        },
        decoration: InputDecoration(
          hintText: "Twitter Username",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget websiteHeader() {
    return Row(
      children: <Widget>[
        Icon(FontAwesomeIcons.link, size: 16.0, color: Colors.black),
        SizedBox(width: 4.0),
        CustomText(
          context: context,
          text: "Website URL",
          textColor: Colors.black,
          textAlign: TextAlign.left,
          fontSize: 16.0,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }

  Widget websiteField() {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: websiteURL,
        cursorColor: Colors.black,
        onSaved: (value) {
          setState(() {
            websiteURL = value.trim();
          });
        },
        decoration: InputDecoration(
          hintText: "Website URL",
          border: InputBorder.none,
        ),
      ),
    );
  }

  //CREATE EVENT
  createEvent() async {
    CustomAlerts().showLoadingAlert(context, "Uploading Event...");
    DateTime startDateTime = DateTime(
      selectedStartDate.year,
      selectedStartDate.day,
      timeFormatter.parse(startTime).hour,
      timeFormatter.parse(startTime).minute,
    );
    WebblenEvent newEvent = WebblenEvent(
      id: widget.eventID == null ? null : widget.eventID,
      authorID: currentUID,
      chatID: eventChatID == null ? null : eventChatID,
      hasTickets: ticketDistro.tickets.isNotEmpty ? true : false,
      flashEvent: false,
      title: eventTitle,
      desc: eventDesc,
      imageURL: eventImgURL == null ? null : eventImgURL,
      isDigitalEvent: isDigitalEvent,
      digitalEventLink: digitalEventLink,
      venueName: venueName,
      streetAddress: eventAddress,
      city: city,
      province: province,
      nearbyZipcodes: nearbyZipcodes,
      lat: lat,
      lon: lon,
      sharedComs: sharedComs,
      tags: tags,
      type: eventType,
      category: eventCategory,
      clicks: eventClicks,
      website: websiteURL,
      fbUsername: fbUsername,
      twitterUsername: twitterUsername,
      instaUsername: instaUsername,
      checkInRadius: 25,
      estimatedTurnout: 0,
      actualTurnout: 0,
      attendees: [],
      eventPayout: 0.0001,
      recurrence: 'none',
      startDateTimeInMilliseconds: startDateTime.millisecondsSinceEpoch,
      startDate: startDate,
      startTime: startTime,
      endDate: endDate,
      endTime: endTime,
      timezone: timezone,
      privacy: privacy,
      reported: false,
      webAppLink: webAppLink == null ? null : webAppLink,
    );
    WebblenUser currentUser = await WebblenUserData().getUserByID(currentUID);
    print(currentUser.uid);
    EventDataService().uploadEvent(newEvent, zipPostalCode, eventImgFile, ticketDistro).then((res) {
      if (res != null) {
        Navigator.of(context).pop();
        ShowAlertDialogService().showActionSuccessDialog(context, "Event Uploaded", "Your Event Has Successfully Been Uploaded", () {
          Navigator.of(context).pop();
          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EventDetailsPage(eventID: res.id, currentUser: currentUser)));
        });

        //newEvent.navigateToEvent(newEvent.id);
      } else {
        CustomAlerts().showErrorAlert(context, "Event Submission Error", "There was an issue creating your event. Please try again");
      }
    });
  }

  submitEvent() {
    FormState formState = formKey.currentState;
    formState.save();
    //bool addressIsValid = setEventAddress();
    if (eventImgFile == null && eventImgURL == null) {
      CustomAlerts().showErrorAlert(context, "Event Image Missing", "Please Set the Image for this Event");
    } else if (eventTitle == null || eventTitle.isEmpty) {
      CustomAlerts().showErrorAlert(context, "Event Title Missing", "Please Give this Event a Title");
    } else if (!isDigitalEvent && (eventAddress == null || eventAddress.isEmpty)) {
      CustomAlerts().showErrorAlert(context, "Event Address Error", "Please Set the Location of this Event");
    } else if (!isDigitalEvent && (zipPostalCode.length != 5)) {
      CustomAlerts().showErrorAlert(context, "Event Address Error", "Please Provide a Better Address for this Event");
    } else if (isDigitalEvent && (digitalEventLink == null || digitalEventLink.isEmpty)) {
      CustomAlerts().showErrorAlert(context, "Event URL Link Error", "Please Provide the Link to this Event");
    } else if (eventDesc == null || eventDesc.isEmpty) {
      CustomAlerts().showErrorAlert(context, "Event Description Missing", "Please Set the Description for this Event");
    } else if (eventCategory == 'Select Event Category') {
      CustomAlerts().showErrorAlert(context, "Event Category Missing", "Please Set the Category for this Event");
    } else if (eventType == "Select Event Type") {
      CustomAlerts().showErrorAlert(context, "Event Type Missing", "Please Select What Type of Event This Is.");
    } else {
      createEvent();
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
      }
      if (widget.eventID != null) {
        EventDataService().getEvent(widget.eventID).then((res) {
          if (res != null) {
            eventTitle = res.title;
            eventDesc = res.desc;
            eventChatID = res.chatID;
            eventImgURL = res.imageURL;
            isDigitalEvent = res.isDigitalEvent;
            digitalEventLink = res.digitalEventLink;
            venueName = res.venueName;
            eventAddress = res.streetAddress;
            city = res.city;
            province = res.province;
            nearbyZipcodes = res.nearbyZipcodes;
            lat = res.lat;
            lon = res.lon;
            sharedComs = res.sharedComs;
            tags = res.tags;
            eventType = res.type;
            eventCategory = res.category;
            eventClicks = res.clicks;
            websiteURL = res.website;
            fbUsername = res.fbUsername;
            twitterUsername = res.twitterUsername;
            instaUsername = res.instaUsername;
            startDateTimeInMilliseconds = res.startDateTimeInMilliseconds;
            startDate = res.startDate;
            startTime = res.startTime;
            endDate = res.endDate;
            endTime = res.endTime;
            timezone = res.timezone;
            privacy = res.privacy;
            webAppLink = res.webAppLink;
            if (res.hasTickets) {
              EventDataService().getEventTicketDistro(res.id).then((res) {
                ticketDistro = res;
                isLoading = false;
                setState(() {});
              });
            } else {
              isLoading = false;
              setState(() {});
            }
          }
        });
      } else {
        startDate = dateFormatter.format(selectedDateTime);
        endDate = dateFormatter.format(selectedDateTime);
        startTime = timeFormatter.format(selectedDateTime.add(Duration(hours: 1)));
        endTime = selectedDateTime.hour == 23
            ? "11:30 PM"
            : timeFormatter.format(selectedDateTime.add(Duration(
                hours: selectedDateTime.hour <= 19
                    ? 4
                    : selectedDateTime.hour == 20 ? 3 : selectedDateTime.hour == 21 ? 2 : selectedDateTime.hour == 22 ? 1 : 0)));
        isLoading = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WebblenAppBar().newEventAppBar(
          context, widget.eventID != null ? 'Editing Event' : 'New Event', widget.eventID != null ? 'Cancel Editing this Event?' : 'Cancel Adding a New Event?',
          () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
          isTypingMultiLine
              ? GestureDetector(
                  onTap: () => dismissKeyboard(),
                  child: Container(
                    margin: EdgeInsets.only(right: 16.0, top: 16.0),
                    child: CustomText(
                      context: context,
                      text: "Done",
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
                            margin: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                SizedBox(height: 24.0),
                                sectionHeader("1", "Event Details"),
                                //EVENT TITLE
                                SizedBox(height: 16.0),
                                fieldHeader("Event Title", true),
                                eventTitleField(),
                                SizedBox(height: 16.0),
                                //EVENT LOCATION
                                isDigitalEvent ? fieldHeader("Event URL Link", true) : fieldHeader("Location", true),
                                isDigitalEvent ? eventDigitalLinkField() : eventLocationField(),
                                isDigitalEvent ? Container() : SizedBox(height: 16.0),
                                isDigitalEvent ? Container() : fieldHeader("Venue Name/Details (Optional)", false),
                                isDigitalEvent ? Container() : eventVenueNameField(),
                                isDigitalEventCheckBox(),
                                SizedBox(height: 16.0),
                                fieldHeader("Event Description", true),
                                eventDescriptionField(),
                                SizedBox(height: 16.0),
                                //EVENT DATE & TIME
                                eventTimeFields(),
                                //EVENT DESCRIPTION
                                SizedBox(height: 16.0),
                                eventTimezoneField(),
                                SizedBox(height: 16.0),
                                sectionHeader("2", "Ticketing"),
                                SizedBox(height: 16.0),
                                //Tickets
                                showTicketForm || ticketDistro.tickets.length > 0 ? fieldHeader("Tickets", false) : Container(),
                                showTicketForm || ticketDistro.tickets.length > 0 ? ticketingFormHeader("ticket") : Container(),
                                ticketDistro.tickets.length > 0 ? ticketListBuilder() : Container(),
                                showTicketForm ? ticketForm() : Container(),
                                //Fees
                                showFeeForm || ticketDistro.fees.length > 0 ? SizedBox(height: 16.0) : Container(),
                                showFeeForm || ticketDistro.fees.length > 0 ? fieldHeader("Fees", false) : Container(),
                                showFeeForm || ticketDistro.fees.length > 0 ? ticketingFormHeader("fee") : Container(),
                                ticketDistro.fees.length > 0 ? feeListBuilder() : Container(),
                                showFeeForm ? feeForm() : Container(),
                                //Discount Codes
                                showDiscountCodeForm || ticketDistro.discountCodes.length > 0 ? SizedBox(height: 16.0) : Container(),
                                showDiscountCodeForm || ticketDistro.discountCodes.length > 0 ? fieldHeader("Discount Codes", false) : Container(),
                                showDiscountCodeForm || ticketDistro.discountCodes.length > 0 ? ticketingFormHeader("discountCode") : Container(),
                                ticketDistro.discountCodes.length > 0 ? discountListBuilder() : Container(),
                                showDiscountCodeForm ? discountCodeForm() : Container(),
                                SizedBox(height: (ticketDistro.tickets.length != null && ticketDistro.tickets.length > 0) ? 16.0 : 0.0),
                                showTicketForm || showFeeForm || showDiscountCodeForm ? Container() : ticketActions(),
                                SizedBox(height: 40.0),
                                sectionHeader("3", "Additional Info"),
                                SizedBox(height: 16.0),
                                fieldHeader("Event Privacy", true),
                                eventPrivacyDropdown(),
                                SizedBox(height: 16.0),
                                fieldHeader("Event Category", true),
                                eventCategoryDropDown(),
                                SizedBox(height: 16.0),
                                fieldHeader("Event Type", true),
                                eventTypeDropDown(),
                                SizedBox(height: 32.0),
                                fieldHeader("Social Links (Optional)", false),
                                SizedBox(height: 8.0),
                                fbSocialHeader(),
                                SizedBox(height: 3.0),
                                fbUsernameField(),
                                SizedBox(height: 8.0),
                                instaSocialHeader(),
                                SizedBox(height: 3.0),
                                instaUsernameField(),
                                SizedBox(height: 8.0),
                                twitterSocialHeader(),
                                SizedBox(height: 3.0),
                                twitterUsernameField(),
                                SizedBox(height: 8.0),
                                websiteHeader(),
                                SizedBox(height: 3.0),
                                websiteField(),
                                SizedBox(height: 32.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 2.0),
                                      child: CustomColorButton(
                                        text: widget.eventID == null ? "Create Event" : "Update Event",
                                        textColor: Colors.black,
                                        backgroundColor: Colors.white,
                                        height: 35.0,
                                        width: 150,
                                        onPressed: () => submitEvent(),
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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_tags/tag.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_location.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/utils/strings.dart';
import 'package:webblen/utils/time.dart';
import 'package:webblen/utils/webblen_image_picker.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';
import 'package:webblen/widgets/widgets_common/common_flushbar.dart';

class CreateRecurringEventPage extends StatefulWidget {
  final WebblenUser currentUser;
  final Community community;

  CreateRecurringEventPage({
    this.currentUser,
    this.community,
  });

  @override
  State<StatefulWidget> createState() {
    return _CreateRecurringEventPageState();
  }
}

class _CreateRecurringEventPageState extends State<CreateRecurringEventPage> {
  //Keys
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final searchScaffoldKey = GlobalKey<ScaffoldState>();
  final _places = GoogleMapsPlaces(apiKey: Strings.googleAPIKEY);
  final eventFormKey = GlobalKey<FormState>();
  final calendarFormKey = GlobalKey<FormState>();
  final addressFormKey = GlobalKey<FormState>();

  bool isTyping = false;

  //Event
  Geoflutterfire geo = Geoflutterfire();
  double lat;
  double lon;
  RecurringEvent newEvent = RecurringEvent(
    dayOfTheMonth: '1st',
    dayOfTheWeek: 'Monday',
    radius: 0.25,
    twitterSite: "",
    fbSite: "",
    website: "",
  );
  List<String> selectedTags = [];
  File eventImage;
  int recurrenceRadioVal = 0;
  int eventTypeRadioVal = 0;
  int dayOfWeekRadioVal = 0;
  List<String> dayOfMonthList = [
    '1st',
    '2nd',
    '3rd',
    '4th',
  ];
  List<String> dayOfWeekList = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  List<String> pageTitles = [
    'Event Details',
    'Add Photo',
    'Event Tags',
    'Event Date',
    'Event Time',
    'External Links',
    'Event Address',
  ];
  int eventPageTitleIndex = 0;
  List<String> _inputTags = [];
  PageController _pageController;

  void nextPage() {
    setState(() {
      eventPageTitleIndex += 1;
    });
    _pageController.nextPage(
      duration: Duration(
        milliseconds: 600,
      ),
      curve: Curves.fastOutSlowIn,
    );
  }

  void previousPage() {
    setState(() {
      eventPageTitleIndex -= 1;
    });
    _pageController.previousPage(
      duration: Duration(
        milliseconds: 600,
      ),
      curve: Curves.easeIn,
    );
  }

  void validateEvent() {
    final form = eventFormKey.currentState;
    form.save();
    if (newEvent.title == null || newEvent.title.isEmpty) {
      AlertFlushbar(
        headerText: "Error",
        bodyText: "Event Title Cannot be Empty",
      ).showAlertFlushbar(context);
    } else if (newEvent.description == null || newEvent.description.isEmpty) {
      AlertFlushbar(
        headerText: "Error",
        bodyText: "Event Description Cannot Be Empty",
      ).showAlertFlushbar(context);
    } else if (eventImage == null) {
      AlertFlushbar(
        headerText: "Error",
        bodyText: "Image is Required",
      ).showAlertFlushbar(context);
    } else if (newEvent.fbSite != null || newEvent.twitterSite != null || newEvent.website != null) {
      bool urlIsValid = true;
      if (newEvent.fbSite != null && newEvent.fbSite.isNotEmpty) {
        urlIsValid = OpenUrl().isValidUrl(newEvent.fbSite);
      }
      if (newEvent.twitterSite != null && newEvent.twitterSite.isNotEmpty) {
        urlIsValid = OpenUrl().isValidUrl(newEvent.twitterSite);
      }
      if (newEvent.website != null && newEvent.website.isNotEmpty) {
        urlIsValid = OpenUrl().isValidUrl(newEvent.website);
      }
      if (urlIsValid) {
        nextPage();
      } else {
        AlertFlushbar(
          headerText: "URL Error",
          bodyText: "URL is Invalid",
        ).showAlertFlushbar(context);
      }
    } else {
      nextPage();
    }
  }

  void validateTags() {
    if (_inputTags == null || _inputTags.isEmpty) {
      AlertFlushbar(
        headerText: "Event Tag Error",
        bodyText: "Event Needs At Least 1 Tag",
      ).showAlertFlushbar(context);
    } else {
      _inputTags.forEach((tag) {
        _inputTags.remove(tag);
        tag = tag.replaceAll(
          RegExp(
            r"/^\s+|\s+$|\s+(?=\s)/g",
          ),
          "",
        );
        _inputTags.add(tag);
      });
      setState(() {
        newEvent.tags = _inputTags;
      });
      nextPage();
    }
  }

  void validateRecurringSchedule() {
    DateFormat timeFormat = DateFormat('h:mm a');
    if (newEvent.startTime == null || newEvent.endTime == null) {
      AlertFlushbar(
        headerText: "Event Time Error",
        bodyText: "Invalid Event Times",
      ).showAlertFlushbar(context);
    } else {
      DateTime startTime = timeFormat.parse(newEvent.startTime);
      DateTime endTime = timeFormat.parse(newEvent.endTime);
      if (endTime.isBefore(startTime)) {
        AlertFlushbar(
          headerText: "Event Time Error",
          bodyText: "Invalid Event Times",
        ).showAlertFlushbar(context);
      } else {
        nextPage();
      }
    }
  }

  void validateAndSubmit() async {
    final form = addressFormKey.currentState;
    form.save();
    if (newEvent.address == null || newEvent.address.isEmpty) {
      AlertFlushbar(
        headerText: "Address Error",
        bodyText: "Address Required",
      ).showAlertFlushbar(context);
    } else {
      ShowAlertDialogService().showLoadingDialog(context);
      newEvent.authorUid = widget.currentUser.uid;
      newEvent.privacy = widget.community.communityType;
      newEvent.comName = widget.community.name;
      newEvent.areaName = widget.community.areaName;
      newEvent.tags = _inputTags;
      newEvent.radius = newEvent.radius * 1.01;
      newEvent.eventType = getEventType();
      newEvent.recurrenceType = getRecurrenceType();
      newEvent.timezone = await Time().getLocalTimezone();
      EventDataService()
          .uploadRecurringEvent(
        eventImage,
        newEvent,
        lat,
        lon,
      )
          .then((error) {
        if (error.isEmpty) {
          Navigator.of(context).pop();
          HapticFeedback.mediumImpact();
          ShowAlertDialogService().showActionSuccessDialog(context, 'Event Created!', "We'll recommend this event to members of the community", () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          });
        } else {
          Navigator.of(context).pop();
          ShowAlertDialogService().showFailureDialog(
            context,
            'Uh Oh',
            'There was an issue uploading your event. Please try again.',
          );
        }
      });
    }
  }

  void selectEventType(int value) {
    setState(() {
      eventTypeRadioVal = value;
    });
  }

  String getEventType() {
    String val;
    if (eventTypeRadioVal == 0) {
      val = 'standard';
    } else if (eventTypeRadioVal == 1) {
      val = 'foodDrink';
    } else if (eventTypeRadioVal == 2) {
      val = 'saleDiscount';
    }
    return val;
  }

  Widget _buildTagsField() {
    return Tags(
      textField: TagsTextField(
        textStyle: TextStyle(
          fontSize: 14.0,
        ),
        onSubmitted: (String str) {
          if (_inputTags.length == 7) {
            AlertFlushbar(
              headerText: "Event Tag Error",
              bodyText: "Events Can Only Have Up to 7 Tags",
            ).showAlertFlushbar(context);
          } else {
            setState(() {
              if (!_inputTags.contains(str)) {
                _inputTags.add(str);
              }
            });
          }
        },
      ),
      itemCount: _inputTags.length, // required
      itemBuilder: (int index) {
        final tag = _inputTags[index];
        return ItemTags(
          key: Key(_inputTags[index]),
          index: index,
          title: tag,
          removeButton: ItemTagsRemoveButton(),
          onRemoved: () {
            setState(() {
              _inputTags.removeAt(index);
            });
          },
        );
      },
    );
  }

  void selectRecurrenceType(int value) {
    setState(() {
      recurrenceRadioVal = value;
    });
  }

  String getRecurrenceType() {
    String val;
    if (recurrenceRadioVal == 0) {
      val = 'daily';
    } else if (recurrenceRadioVal == 1) {
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
    if (eventImage != null) {
      setState(() {});
    }
  }

  void handleSelectedTime(DateTime selectedDate, bool isStartDate) {
    DateFormat timeFormat = DateFormat(
      "h:mm a",
    );
    String newTime = timeFormat.format(selectedDate).toString();
    if (selectedDate.hour == 12 || selectedDate.hour == 0) {
      if (newTime.contains('AM')) {
        newTime = newTime.replaceAll(
          'AM',
          'PM',
        );
      } else {
        newTime = newTime.replaceAll(
          'PM',
          'AM',
        );
      }
    }
    if (isStartDate) {
      setState(() {
        newEvent.startTime = newTime;
      });
    } else {
      setState(() {
        newEvent.endTime = newTime;
      });
    }
  }

  showPickerDateTime(BuildContext context, String dateType) {
    Picker(
      adapter: new DateTimePickerAdapter(
        type: PickerDateTimeType.kHM_AP,
        strAMPM: [
          'AM',
          'PM',
        ],
      ),
      onConfirm: (
        Picker picker,
        List value,
      ) {
        DateTime selectedDate = (picker.adapter as DateTimePickerAdapter).value;
        if (dateType == 'start') {
          handleSelectedTime(
            selectedDate,
            true,
          );
        } else {
          handleSelectedTime(
            selectedDate,
            false,
          );
        }
      },
    ).show(homeScaffoldKey.currentState);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget addImageButton() {
      return GestureDetector(
        onTap: () => ShowAlertDialogService().showImageSelectDialog(
          context,
          () => setEventImage(true),
          () => setEventImage(false),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.black12,
          ),
          child: eventImage == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.camera_alt,
                      size: 40.0,
                      color: FlatColors.londonSquare,
                    ),
                    Fonts().textW500(
                      '1:1',
                      16.0,
                      FlatColors.londonSquare,
                      TextAlign.center,
                    ),
                  ],
                )
              : Image.file(
                  eventImage,
                  fit: BoxFit.cover,
                ),
        ),
      );
    }

    Widget _buildEventTitleField() {
      return Container(
        margin: EdgeInsets.only(
          left: 8.0,
          top: 8.0,
          right: 8.0,
        ),
        decoration: BoxDecoration(
          color: FlatColors.textFieldGray,
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        child: TextFormField(
          decoration: InputDecoration(
            hintText: "Event Title",
            contentPadding: EdgeInsets.only(
              left: 8,
              top: 8,
              bottom: 8,
            ),
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
            BlacklistingTextInputFormatter(
              RegExp(
                "[\\-|\\#|\\[|\\]|\\%|\\^|\\*|\\+|\\=|\\_|\\~|\\<|\\>|\\,|\\@|\\(|\\)|\\'|\\{|\\}|\\.]",
              ),
            ),
          ],
          textInputAction: TextInputAction.done,
          autocorrect: false,
        ),
      );
    }

    Widget _buildEventDescriptionField() {
      return Container(
        height: 180,
        margin: EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: 16,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width - 16,
        ),
        decoration: BoxDecoration(
          color: FlatColors.textFieldGray,
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
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

    Widget _buildEventTypeSelectField() {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
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
              ],
            ),
          ],
        ),
      );
    }

    Widget _buildRecurrenceSelectField() {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Fonts().textW700(
              "Frequency",
              20.0,
              FlatColors.darkGray,
              TextAlign.left,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Fonts().textW500(
                        "Daily",
                        16.0,
                        FlatColors.darkGray,
                        TextAlign.left,
                      ),
                      Radio<int>(
                        value: 0,
                        groupValue: recurrenceRadioVal,
                        onChanged: selectRecurrenceType,
                        activeColor: FlatColors.webblenRed,
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Fonts().textW500(
                        "Weekly",
                        16.0,
                        FlatColors.darkGray,
                        TextAlign.left,
                      ),
                      Radio<int>(
                        value: 1,
                        groupValue: recurrenceRadioVal,
                        onChanged: selectRecurrenceType,
                        activeColor: FlatColors.webblenRed,
                      )
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Fonts().textW500(
                        "Monthly",
                        16.0,
                        FlatColors.darkGray,
                        TextAlign.left,
                      ),
                      Radio<int>(
                        value: 2,
                        groupValue: recurrenceRadioVal,
                        onChanged: selectRecurrenceType,
                        activeColor: FlatColors.webblenRed,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget _buildDayOfSelectField() {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        margin: EdgeInsets.only(
          bottom: 4.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            recurrenceRadioVal != 0
                ? Fonts().textW700(
                    "Every",
                    20.0,
                    FlatColors.darkGray,
                    TextAlign.left,
                  )
                : Container(),
            SizedBox(width: 8.0),
            recurrenceRadioVal == 2
                ? DropdownButton<String>(
                    isDense: true,
                    value: newEvent.dayOfTheMonth,
                    underline: Container(),
                    icon: Container(),
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: FlatColors.electronBlue,
                    ),
                    items: dayOfMonthList.map((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        newEvent.dayOfTheMonth = val;
                      });
                    })
                : Container(),
            recurrenceRadioVal != 0
                ? DropdownButton<String>(
                    isDense: true,
                    value: newEvent.dayOfTheWeek,
                    underline: Container(),
                    icon: Container(),
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500,
                      color: FlatColors.electronBlue,
                    ),
                    items: dayOfWeekList.map((String val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        newEvent.dayOfTheWeek = val;
                      });
                    })
                : Container()
          ],
        ),
      );
    }

    Widget _buildTimeFields() {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        margin: EdgeInsets.only(
          bottom: 4.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            recurrenceRadioVal == 0
                ? Fonts().textW700(
                    "Everyday From",
                    20.0,
                    FlatColors.darkGray,
                    TextAlign.left,
                  )
                : Fonts().textW700(
                    "From",
                    20.0,
                    FlatColors.darkGray,
                    TextAlign.left,
                  ),
            Container(
                margin: EdgeInsets.only(
                  left: 8.0,
                  right: 8.0,
                ),
                child: GestureDetector(
                  child: Fonts().textW500(newEvent.startTime == null ? "Start Time" : newEvent.startTime, 18.0, FlatColors.electronBlue, TextAlign.left),
                  onTap: () => showPickerDateTime(
                    context,
                    'start',
                  ),
                )),
            Fonts().textW700(
              "to",
              20.0,
              FlatColors.darkGray,
              TextAlign.left,
            ),
            Container(
              margin: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: Fonts().textW500(
                      newEvent.endTime == null ? "End Time" : newEvent.endTime,
                      18.0,
                      FlatColors.electronBlue,
                      TextAlign.left,
                    ),
                    onTap: () => showPickerDateTime(
                      context,
                      'end',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildFBUrlField() {
      return Container(
        margin: EdgeInsets.only(
          left: 16.0,
          top: 4.0,
          right: 8.0,
        ),
        child: TextFormField(
          initialValue: "",
          maxLines: 1,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16.0,
            fontFamily: 'Barlow',
            fontWeight: FontWeight.w500,
          ),
          autofocus: false,
          onSaved: (url) {
            if (url.isNotEmpty) {
              if (!url.contains('http://') || !url.contains('https://')) {
                if (!url.contains('www.')) {
                  url = 'http://www.' + url;
                } else {
                  url = 'http://' + url;
                }
              }
            }

            newEvent.fbSite = url;
          },
          inputFormatters: [
            BlacklistingTextInputFormatter(
              RegExp(
                "[\\ |\\,]",
              ),
            ),
          ],
          decoration: InputDecoration(
            icon: Icon(
              FontAwesomeIcons.facebook,
              color: FlatColors.darkGray,
              size: 18,
            ),
            border: InputBorder.none,
            hintText: "Facebook Page URL",
            counterStyle: TextStyle(
              fontFamily: 'Barlow',
            ),
            contentPadding: EdgeInsets.fromLTRB(
              0.0,
              10.0,
              10.0,
              10.0,
            ),
          ),
        ),
      );
    }

    Widget _buildTwitterUrlField() {
      return Container(
        margin: EdgeInsets.only(
          left: 16.0,
          top: 4.0,
          right: 8.0,
        ),
        child: TextFormField(
          initialValue: "",
          maxLines: 1,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16.0,
            fontFamily: 'Barlow',
            fontWeight: FontWeight.w500,
          ),
          autofocus: false,
          inputFormatters: [
            BlacklistingTextInputFormatter(
              RegExp(
                "[\\#|\\[|\\]|\\%|\\^|\\*|\\+|\\=|\\_|\\~|\\<|\\>|\\,|\\(|\\)|\\'|\\{|\\}]",
              ),
            ),
          ],
          onSaved: (value) {
            if (value != null && value.isNotEmpty) {
              newEvent.twitterSite = 'https://www.twitter.com/' + value;
              setState(() {});
            }
          },
          decoration: InputDecoration(
            icon: Icon(
              FontAwesomeIcons.twitter,
              color: FlatColors.darkGray,
              size: 18,
            ),
            border: InputBorder.none,
            hintText: "@twitter_handle",
            counterStyle: TextStyle(
              fontFamily: 'Barlow',
            ),
            contentPadding: EdgeInsets.fromLTRB(
              0.0,
              10.0,
              10.0,
              10.0,
            ),
          ),
        ),
      );
    }

    Widget _buildWebsiteUrlField() {
      return Container(
        margin: EdgeInsets.only(
          left: 16.0,
          top: 4.0,
          right: 8.0,
        ),
        child: TextFormField(
          initialValue: "",
          maxLines: 1,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16.0,
            fontFamily: 'Barlow',
            fontWeight: FontWeight.w500,
          ),
          autofocus: false,
          inputFormatters: [
            BlacklistingTextInputFormatter(
              RegExp(
                "[\\ |\\,]",
              ),
            ),
          ],
          onSaved: (url) {
            if (url.isNotEmpty) {
              if (!url.contains('http://') || !url.contains('https://')) {
                if (!url.contains('www.')) {
                  url = 'http://www.' + url;
                } else {
                  url = 'http://' + url;
                }
              }
            }
            newEvent.website = url;
          },
          decoration: InputDecoration(
            icon: Icon(
              FontAwesomeIcons.globe,
              color: FlatColors.darkGray,
              size: 18,
            ),
            border: InputBorder.none,
            hintText: "Website URL",
            counterStyle: TextStyle(
              fontFamily: 'Barlow',
            ),
            contentPadding: EdgeInsets.fromLTRB(
              0.0,
              10.0,
              10.0,
              10.0,
            ),
          ),
        ),
      );
    }

    Widget _buildSearchAutoComplete() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Fonts().textW500(
              newEvent.address == null || newEvent.address.isEmpty ? "Set Address" : "${newEvent.address}", 16.0, FlatColors.darkGray, TextAlign.center),
          SizedBox(
            height: 16.0,
          ),
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
                        SnackBar(
                          content: Text(
                            res.errorMessage,
                          ),
                        ),
                      );
                    },
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
                  setState(() {
                    lat = detail.result.geometry.location.lat;
                    lon = detail.result.geometry.location.lng;
                    newEvent.address = p.description.replaceAll(
                      ', USA',
                      '',
                    );
                  });
                },
                child: Text(
                  "Search Address",
                ),
              ),
              RaisedButton(
                color: Colors.white70,
                onPressed: () async {
                  LocationService().getCurrentLocation(context).then((location) {
                    if (this.mounted) {
                      if (location == null) {
                        ShowAlertDialogService().showFailureDialog(
                          context,
                          'Cannot Retrieve Location',
                          'Location Permission Disabled',
                        );
                      } else {
                        var currentLocation = location;
                        lat = currentLocation.latitude;
                        lon = currentLocation.longitude;
                        LocationService()
                            .getAddressFromLatLon(
                          lat,
                          lon,
                        )
                            .then((foundAddress) {
                          newEvent.address = foundAddress.replaceAll(
                            ', USA',
                            '',
                          );
                          setState(() {});
                        });
                      }
                    }
                  });
                },
                child: Text(
                  "Current Location",
                ),
              ),
            ],
          ),
        ],
      );
    }

    Widget _buildDistanceSlider() {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16.0,
        ),
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
    final formButton1 = NewEventFormButton(
      "Next",
      FlatColors.blackPearl,
      Colors.white,
      this.validateEvent,
    );
    final formButton2 = NewEventFormButton(
      "Next",
      FlatColors.blackPearl,
      Colors.white,
      this.validateTags,
    );
    final formButton3 = NewEventFormButton(
      "Next",
      FlatColors.blackPearl,
      Colors.white,
      this.validateRecurringSchedule,
    );
    final submitButton = NewEventFormButton(
      "Submit",
      FlatColors.blackPearl,
      Colors.white,
      this.validateAndSubmit,
    );
    final backButton = FlatBackButton(
      "Back",
      FlatColors.blackPearl,
      Colors.white,
      this.previousPage,
    );

    //**Title, Description, Dates, URLS
    final eventFormPage1 = Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Form(
          key: eventFormKey,
          child: ListView(
            children: <Widget>[
              addImageButton(),
              _buildEventTitleField(),
              SizedBox(
                height: 8.0,
              ),
              _buildEventDescriptionField(),
              Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  top: 8.0,
                  right: 16.0,
                ),
                child: Fonts().textW700(
                  "Event Type",
                  18.0,
                  FlatColors.darkGray,
                  TextAlign.left,
                ),
              ),
              _buildEventTypeSelectField(),
              Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  top: 16.0,
                  right: 16.0,
                ),
                child: Fonts().textW700(
                  "External Links (Optional)",
                  18.0,
                  FlatColors.darkGray,
                  TextAlign.left,
                ),
              ),
              _buildFBUrlField(),
              _buildTwitterUrlField(),
              _buildWebsiteUrlField(),
              formButton1
            ],
          ),
        ),
      ),
    );

    //**Tags Page
    final eventFormPage2 = Container(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
          ),
          _buildTagsField(),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          formButton2,
          backButton,
        ],
      ),
    );

    //Recurring Schedule
    final eventFormPage3 = Container(
      child: ListView(
        children: <Widget>[
          Form(
            key: calendarFormKey,
            child: Column(
              children: <Widget>[
                _buildRecurrenceSelectField(),
                _buildDayOfSelectField(),
                _buildTimeFields(),
                formButton3,
              ],
            ),
          ),
        ],
      ),
    );

    //**Address Page
    final eventFormPage4 = Container(
      child: ListView(
        children: <Widget>[
          Form(
            key: addressFormKey,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.13,
                ),
                _buildSearchAutoComplete(),
                SizedBox(
                  height: 32.0,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 16.0,
                    ),
                    Fonts().textW500(
                      'Notify Users Within: ',
                      16.0,
                      FlatColors.darkGray,
                      TextAlign.left,
                    ),
                    Fonts().textW400(
                      '${(newEvent.radius.toStringAsFixed(2))} Miles ',
                      16.0,
                      FlatColors.darkGray,
                      TextAlign.left,
                    ),
                  ],
                ),
                _buildDistanceSlider(),
                SizedBox(
                  height: 32.0,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 16.0,
                    ),
                    Fonts().textW700(
                      'Estimated Reach: ',
                      16.0,
                      FlatColors.darkGray,
                      TextAlign.left,
                    ),
                    Fonts().textW400(
                      '${(newEvent.radius.round() * 13)}',
                      16.0,
                      FlatColors.darkGray,
                      TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(
                  height: 4.0,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 16.0,
                    ),
                    Fonts().textW700(
                      'Total Cost: ',
                      16.0,
                      FlatColors.darkGray,
                      TextAlign.left,
                    ),
                    Fonts().textW400(
                      'FREE',
                      16.0,
                      FlatColors.darkGray,
                      TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(
                  height: 30.0,
                ),
                submitButton,
                backButton,
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: WebblenAppBar().newEventAppBar(context, 'New Regular Event', widget.community.name, 'Cancel Adding a New Event?', () {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      },
          isTyping
              ? GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Fonts().textW500('Done', 16.0, Colors.black, TextAlign.right),
                )
              : Container()),
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
            eventFormPage3,
            eventFormPage4,
          ],
        ),
      ),
    );
  }
}

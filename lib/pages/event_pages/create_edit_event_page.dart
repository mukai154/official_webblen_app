import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_tags/tag.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'package:webblen/firebase_data/stripe_data.dart';
import 'package:webblen/models/community.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/event_ticket_distribution.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
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

class CreateEditEventPage extends StatefulWidget {
  final WebblenUser currentUser;
  final Community community;
  final bool isRecurring;
  final Event eventToEdit;
  final bool hasTickets;

  CreateEditEventPage({
    this.currentUser,
    this.community,
    this.isRecurring,
    this.eventToEdit,
    this.hasTickets,
  });

  @override
  State<StatefulWidget> createState() {
    return _CreateEditEventPageState();
  }
}

class _CreateEditEventPageState extends State<CreateEditEventPage> {
  DateFormat dateFormatter = DateFormat('MMM dd, yyyy');
  DateFormat timeFormatter = DateFormat('h:mm a');
  //Keys
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final searchScaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapsPlaces _places = GoogleMapsPlaces(
    apiKey: Strings.googleAPIKEY,
  );
  GlobalKey<FormState> page1FormKey;
  final page2FormKey = GlobalKey<FormState>();
  final page3FormKey = GlobalKey<FormState>();
  final page4FormKey = GlobalKey<FormState>();
  final page5FormKey = GlobalKey<FormState>();
  final page6FormKey = GlobalKey<FormState>();
  final page7FormKey = GlobalKey<FormState>();
  final ticketFormKey = GlobalKey<FormState>();
  final feeFormKey = GlobalKey<FormState>();

  bool hasTickets = false;
  bool isTyping = false;

  //Event
  Geoflutterfire geo = Geoflutterfire();
  double lat;
  double lon;
  Event newEvent = Event(
    radius: 0.25,
    fbSite: "",
    twitterSite: "",
    website: "",
  );
  List<String> suggestedTags = [];
  List<String> selectedTags = [];
  File eventImage;
  bool showStartCalendar = false;
  bool showEndCalendar = false;
  String startDate = "";
  String endDate = "";
  String startTime = "";
  String endTime = "";
  int eventTypeRadioVal = 0;
  int eventTicketRadioValue = 0;
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
  List _inputTags = [];

  // EVENT TICKETING
  MoneyMaskedTextController moneyMaskedTextController =
      MoneyMaskedTextController(leftSymbol: "\$", precision: 2, decimalSeparator: '.', thousandSeparator: ',');

  List eventTickets = [];
  String ticketName;
  String ticketPrice;
  String ticketQuantity;
  List eventFees = [];
  String feeName;
  String feeAmount;

  //Paging & Page Behavior
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

  void addressButtonBackAction() {
    bool hasTickets = getEventTicketValueChange();
    if (hasTickets) {
      _pageController.previousPage(
        duration: Duration(
          milliseconds: 600,
        ),
        curve: Curves.easeIn,
      );
    } else {
      _pageController.animateToPage(2, duration: Duration(milliseconds: 600), curve: Curves.easeIn);
    }
  }

  void dismissKeyboard() {
    FocusScope.of(context).unfocus();
    isTyping = false;
    setState(() {});
  }

  void alertFormError(String header, String description) {
    AlertFlushbar(
      headerText: header,
      bodyText: description,
    ).showAlertFlushbar(context);
  }

  //FORM VALIDATIONS

  void validateEventDetails() {
    bool formIsValid = true;
    final form = page1FormKey.currentState;
    form.save();
    newEvent.eventType = getEventTypeRadioValue();

    //EVENT DETAILS VALIDATIONS
    if (newEvent.title == null || newEvent.title.isEmpty) {
      formIsValid = false;
      alertFormError("Error", "Event Title Cannot be Empty");
    } else if (newEvent.description == null || newEvent.description.isEmpty) {
      formIsValid = false;
      alertFormError("Error", "Event Description Cannot be Empty");
    } else if (eventImage == null && widget.eventToEdit == null) {
      formIsValid = false;
      alertFormError("Error", "Image is Required");
    }

    //EVENT URL VALIDATIONS
    if (newEvent.fbSite != null && newEvent.fbSite.isNotEmpty) {
      bool urlIsValid = true;
      urlIsValid = OpenUrl().isValidUrl(newEvent.fbSite);
      if (!urlIsValid) {
        alertFormError("FaceBook URL Error", "The FaceBook URL Below is Invalid");
      }
    }
    if (newEvent.twitterSite != null && newEvent.twitterSite.isNotEmpty) {
      bool urlIsValid = true;
      urlIsValid = OpenUrl().isValidUrl(newEvent.twitterSite);
      if (!urlIsValid) {
        alertFormError("Twitter URL Error", "The Twitter URL Below is Invalid");
      }
    }
    if (newEvent.website != null && newEvent.website.isNotEmpty) {
      bool urlIsValid = true;
      urlIsValid = OpenUrl().isValidUrl(newEvent.website);
      if (!urlIsValid) {
        alertFormError("Website URL Error", "The Website URL Below is Invalid");
      }
    }

    //EVENT DATE VALIDATIONS
    if (widget.isRecurring == null || widget.isRecurring == false) {
      if (newEvent.startDateInMilliseconds == null) {
        formIsValid = false;
        alertFormError("Error", "Event Needs a Start Date");
      } else if (newEvent.endDateInMilliseconds == null) {
        formIsValid = false;
        alertFormError("Error", "Event Needs an End Date");
      }
    }

    if (formIsValid) {
      nextPage();
    }
  }

  void validateTags() {
    if (_inputTags == null || _inputTags.isEmpty) {
      alertFormError("Event Tag Error", "Event Needs At Least 1 Tag");
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

  void validateTicketStatus() {
    bool hasTickets = getEventTicketValueChange();
    if (hasTickets) {
      if (widget.eventToEdit != null) {
        loadEventTickets();
      } else {
        ShowAlertDialogService().showLoadingDialog(context);
        StripeDataService().checkIfStripeSetup(widget.currentUser.uid).then((res) {
          Navigator.of(context).pop();
          if (res = true) {
            nextPage();
          } else {
            ShowAlertDialogService()
                .showFailureDialog(context, "Earnings Account Required", "To Sell Tickets, Please Create an Earnings Account from Your Dashboard");
          }
        });
      }
    } else {
      _pageController.animateToPage(
        4,
        duration: Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void validateTicketPage() {
    if (eventTickets.isEmpty) {
      alertFormError("Error", "Please Create At Least 1 Ticket for this Event");
    } else {
      nextPage();
    }
  }

  void validateTicketForm() {
    final form = ticketFormKey.currentState;
    form.save();
    print(ticketPrice);
    if (ticketName == null || ticketName.isEmpty) {
      alertFormError("Error", "Ticket Name Required");
    } else if (ticketQuantity == null || ticketQuantity.isEmpty) {
      alertFormError("Error", "Ticket Quantity Required");
    } else if (ticketPrice == null || ticketPrice.isEmpty) {
      alertFormError("Error", "Ticket Price Required");
    } else {
      Map<String, dynamic> eventTicket = {
        "ticketName": ticketName,
        "ticketPrice": ticketPrice,
        "ticketQuantity": ticketQuantity,
        //"ticketDesc": ticketDesc == null ? null : ticketDesc
      };
      eventTickets.add(eventTicket);
      Navigator.of(context).pop();
      ticketName = null;
      ticketPrice = null;
      ticketQuantity = null;
      //ticketDesc = null;
      setState(() {});
    }
  }

  void validateFeeForm() {
    final form = feeFormKey.currentState;
    form.save();
    if (feeName == null || feeName.isEmpty) {
      alertFormError("Error", "Fee Name Required");
    } else if (feeAmount == null || feeAmount.isEmpty) {
      alertFormError("Error", "Fee Price Required");
    } else {
      Map<String, dynamic> eventFee = {
        "feeName": feeName,
        "feeAmount": feeAmount,
      };
      eventFees.add(eventFee);
      Navigator.of(context).pop();
      feeName = null;
      feeAmount = null;
      setState(() {});
    }
  }

  void validateAddress() {
    final form = page7FormKey.currentState;
    form.save();
    if (newEvent.address == null || newEvent.address.isEmpty) {
      alertFormError("Address Error", "Address Required");
    } else if (eventTickets.isEmpty && eventFees.isEmpty) {
      validateAndSubmit();
    } else {
      nextPage();
    }
  }

  void validateAndSubmit() {
    ShowAlertDialogService().showLoadingDialog(context);
    if (newEvent.endDateInMilliseconds == null && newEvent.startDateInMilliseconds != null) {
      DateTime eventStart = DateTime.fromMillisecondsSinceEpoch(newEvent.startDateInMilliseconds);
      newEvent.startDateInMilliseconds = eventStart.millisecondsSinceEpoch;
      newEvent.endDateInMilliseconds = eventStart
          .add(
            Duration(
              hours: 2,
            ),
          )
          .millisecondsSinceEpoch;
    }
    if (widget.eventToEdit == null) {
      eventTickets.isNotEmpty ? newEvent.hasTickets = true : newEvent.hasTickets = false;
      newEvent.authorUid = widget.currentUser.uid;
      newEvent.attendees = [];
      newEvent.privacy = widget.community.communityType;
      newEvent.flashEvent = false;
      newEvent.eventPayout = 0.00;
      newEvent.estimatedTurnout = 0;
      newEvent.actualTurnout = 0;
      newEvent.pointsDistributedToUsers = false;
      newEvent.views = 0;
      newEvent.communityName = widget.community.name;
      newEvent.communityAreaName = widget.community.areaName;
    }
    newEvent.tags = _inputTags;
    if (!widget.isRecurring) {
      newEvent.recurrence = 'none';
    }
    if (widget.eventToEdit != null) {
      EventDataService().updateEvent(newEvent, eventTickets, eventFees).then((error) {
        if (error.isEmpty) {
          Navigator.of(context).pop();
          HapticFeedback.mediumImpact();
          ShowAlertDialogService().showActionSuccessDialog(context, 'Event Updated!', "Your event has been updated.", () {
            PageTransitionService(
              context: context,
            ).returnToRootPage();
          });
        } else {
          Navigator.of(context).pop();
          ShowAlertDialogService().showFailureDialog(
            context,
            'Uh Oh',
            'There was an issue updating your event. Please try again.',
          );
        }
      });
    } else {
      EventDataService().uploadEvent(eventImage, newEvent, lat, lon, eventTickets, eventFees).then((error) {
        if (error.isEmpty) {
          Navigator.of(context).pop();
          HapticFeedback.mediumImpact();
          ShowAlertDialogService().showActionSuccessDialog(context, 'Event Created!', "Your event has been posted and added to your calendar.", () {
            PageTransitionService(
              context: context,
            ).returnToRootPage();
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

  void handleEventRadioButtonChange(int value) {
    setState(() {
      eventTypeRadioVal = value;
    });
  }

  String getEventTypeRadioValue() {
    String val = 'standard';
    if (eventTypeRadioVal == 1) {
      val = 'foodDrink';
    } else if (eventTypeRadioVal == 2) {
      val = 'saleDiscount';
    }
    return val;
  }

  void handleEventTicketValueChange(int value) {
    setState(() {
      eventTypeRadioVal = value;
    });
  }

  bool getEventTicketValueChange() {
    if (eventTicketRadioValue == 0) {
      hasTickets = true;
    } else if (eventTicketRadioValue == 1) {
      hasTickets = false;
    }
    setState(() {});
    return hasTickets;
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

  void handleNewDate(DateTime selectedDate, bool isStartDate) {
    if (selectedDate.hour == 0 || selectedDate.hour == 12) {
      selectedDate = selectedDate.add(
        Duration(
          hours: 12,
        ),
      );
    }
    ScaffoldState scaffold = homeScaffoldKey.currentState;
    DateTime today = DateTime.now().subtract(
      Duration(
        hours: 1,
      ),
    );
    if (selectedDate.isBefore(today)) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(
            "Invalid Start Date",
          ),
          backgroundColor: Colors.red,
          duration: Duration(
            milliseconds: 800,
          ),
        ),
      );
    } else {
      if (isStartDate) {
        setState(() {
          newEvent.startDate = dateFormatter.format(selectedDate);
          newEvent.startTime = timeFormatter.format(selectedDate);
          newEvent.startDateInMilliseconds = selectedDate.millisecondsSinceEpoch;
          newEvent.timezone = Time().getLocalTimezone();
        });
      } else {
        if (selectedDate.millisecondsSinceEpoch < newEvent.startDateInMilliseconds) {
          scaffold.showSnackBar(
            SnackBar(
              content: Text(
                "Invalid End Date",
              ),
              backgroundColor: Colors.red,
              duration: Duration(
                milliseconds: 800,
              ),
            ),
          );
        } else {
          setState(() {
            newEvent.endDate = dateFormatter.format(selectedDate);
            newEvent.endTime = timeFormatter.format(selectedDate);
            newEvent.endDateInMilliseconds = selectedDate.millisecondsSinceEpoch;
          });
        }
      }
    }
  }

  showPickerDateTime(BuildContext context, String dateType) {
    Picker(
      adapter: DateTimePickerAdapter(
        customColumnType: [
          1,
          2,
          0,
          7,
          4,
          6,
        ],
        isNumberMonth: false,
        yearBegin: DateTime.now().year,
        yearEnd: DateTime.now().year + 6,
      ),
      onConfirm: (
        Picker picker,
        List value,
      ) {
        DateTime selectedDate = (picker.adapter as DateTimePickerAdapter).value;
        if (dateType == 'start') {
          handleNewDate(
            selectedDate,
            true,
          );
        } else {
          handleNewDate(
            selectedDate,
            false,
          );
        }
      },
    ).show(homeScaffoldKey.currentState);
  }

  Widget _buildTagsField() {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 1.0,
      ),
      child: Tags(
        textField: TagsTextField(
          textStyle: TextStyle(
            fontSize: 14.0,
          ),
          onSubmitted: (String str) {
            if (_inputTags.length == 7) {
              alertFormError("Event Tag Error", "Events Can Only Have P to 7 Tags");
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
      ),
    );
  }

  Widget ticketAndFeeListBuilder(bool isTicket, bool isStatic) {
    return Container(
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: isTicket ? eventTickets.length : eventFees.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: null,
              child: Container(
                margin: EdgeInsets.only(bottom: 16.0),
                height: 50.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                isTicket ? FontAwesomeIcons.ticketAlt : FontAwesomeIcons.dollarSign,
                                color: Colors.black,
                                size: 18.0,
                              ),
                              SizedBox(width: 16.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Fonts().textW400(
                                    isTicket ? eventTickets[index]["ticketName"] : eventFees[index]["feeName"],
                                    18.0,
                                    Colors.black,
                                    TextAlign.left,
                                  ),
                                  Fonts().textW300(
                                    isTicket
                                        ? "${eventTickets[index]["ticketPrice"]} each | Amount Available: ${eventTickets[index]["ticketQuantity"]}"
                                        : "+ ${eventFees[index]["feeAmount"]}",
                                    12.0,
                                    Colors.black,
                                    TextAlign.left,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        isStatic
                            ? Container()
                            : IconButton(
                                icon: Icon(FontAwesomeIcons.times, color: Colors.black38, size: 16.0),
                                onPressed: () {
                                  isTicket ? eventTickets.remove(eventTickets[index]) : eventFees.remove(eventFees[index]);
                                  setState(() {});
                                },
                              ),
                      ],
                    ),
                    Divider(
                      height: 1.0,
                      thickness: 1.0,
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Future<Null> loadEventTickets() async {
    ShowAlertDialogService().showLoadingDialog(context);
    EventTicketDistribution ticketDistro = await EventDataService().getEventTicketDistro(widget.eventToEdit.eventKey);
    Navigator.of(context).pop();
    eventTickets = ticketDistro.tickets.toList(growable: true);
    eventFees = ticketDistro.fees.toList(growable: true);
    setState(() {});
    nextPage();
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    page1FormKey = GlobalKey<FormState>();
    if (widget.eventToEdit != null) {
      newEvent = widget.eventToEdit;
      _inputTags = newEvent.tags.toList(
        growable: true,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat(
      'MMM dd, yyyy | h:mm a',
    );

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
          child: widget.eventToEdit != null
              ? eventImage == null
                  ? CachedNetworkImage(
                      imageUrl: newEvent.imageURL,
                      fit: BoxFit.contain,
                    )
                  : Image.file(
                      eventImage,
                      fit: BoxFit.contain,
                    )
              : eventImage == null
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
                        )
                      ],
                    )
                  : Image.file(
                      eventImage,
                      fit: BoxFit.contain,
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
        child: TextFormField(
          onTap: () {
            isTyping = true;
            setState(() {});
          },
          initialValue: newEvent != null && newEvent.title != null ? newEvent.title : "",
          decoration: InputDecoration(
            hintText: "Event Title",
            contentPadding: EdgeInsets.only(
              left: 8,
              top: 8,
              bottom: 8,
            ),
            border: InputBorder.none,
          ),
          onEditingComplete: () => dismissKeyboard(),
          onSaved: (val) => newEvent.title = val,
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
        child: TextFormField(
          onTap: () {
            isTyping = true;
            setState(() {});
          },
          initialValue: newEvent != null && newEvent.description != null ? newEvent.description : "",
          decoration: InputDecoration(
            hintText: "Event Description",
            contentPadding: EdgeInsets.all(8),
            border: InputBorder.none,
          ),
          onEditingComplete: () => dismissKeyboard(),
          onSaved: (val) {
            newEvent.description = val;
            isTyping = false;
            setState(() {});
          },
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: "Helvetica Neue",
          ),
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          autocorrect: false,
        ),
      );
    }

    Widget _buildStartDateField() {
      return Container(
        margin: EdgeInsets.only(
          left: 16.0,
          top: 8.0,
          right: 16.0,
        ),
        child: GestureDetector(
          child: newEvent.startDateInMilliseconds == null
              ? Fonts().textW500(
                  "Start Date & Time",
                  18.0,
                  FlatColors.londonSquare,
                  TextAlign.left,
                )
              : Fonts().textW500(
                  "${formatter.format(
                    DateTime.fromMillisecondsSinceEpoch(newEvent.startDateInMilliseconds),
                  )}",
                  18.0,
                  FlatColors.electronBlue,
                  TextAlign.left),
          onTap: () => showPickerDateTime(
            context,
            'start',
          ),
        ),
      );
    }

    Widget _buildEndDateField() {
      return newEvent.startDateInMilliseconds == null
          ? Container()
          : Container(
              margin: EdgeInsets.only(
                left: 16.0,
                top: 8.0,
                right: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: 1.0,
                      ),
                      child: newEvent.endDateInMilliseconds == null
                          ? Fonts().textW500(
                              "End Date & Time",
                              18.0,
                              FlatColors.londonSquare,
                              TextAlign.left,
                            )
                          : Fonts().textW500(
                              "${formatter.format(
                                DateTime.fromMillisecondsSinceEpoch(newEvent.endDateInMilliseconds),
                              )}",
                              18.0,
                              FlatColors.electronBlue,
                              TextAlign.left),
                    ),
                    onTap: () => showPickerDateTime(
                      context,
                      'end',
                    ),
                  ),
                  newEvent.endDateInMilliseconds == null
                      ? Container()
                      : IconButton(
                          icon: Icon(
                            FontAwesomeIcons.trash,
                            color: Colors.black38,
                            size: 14.0,
                          ),
                          onPressed: () {
                            setState(() {
                              newEvent.endDateInMilliseconds = null;
                            });
                          },
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
            color: Colors.black,
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
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            icon: Icon(
              FontAwesomeIcons.facebook,
              color: FlatColors.darkGray,
              size: 18,
            ),
            border: InputBorder.none,
            hintText: "Facebook Page URL",
            counterStyle: TextStyle(
              fontFamily: 'Helvetica Neue',
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
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: TextFormField(
            initialValue: "",
            maxLines: 1,
            style: TextStyle(
              color: Colors.black,
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
                fontFamily: 'Helvetica Neue',
              ),
              contentPadding: EdgeInsets.fromLTRB(
                0.0,
                10.0,
                10.0,
                10.0,
              ),
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
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: 1.0,
          ),
          child: TextFormField(
            initialValue: "",
            maxLines: 1,
            style: TextStyle(
              color: Colors.black,
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
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              icon: Icon(
                FontAwesomeIcons.globe,
                color: FlatColors.darkGray,
                size: 18,
              ),
              border: InputBorder.none,
              hintText: "Website URL",
              counterStyle: TextStyle(
                fontFamily: 'Helvetica Neue',
              ),
              contentPadding: EdgeInsets.fromLTRB(
                0.0,
                10.0,
                10.0,
                10.0,
              ),
            ),
          ),
        ),
      );
    }

    Widget _buildEventTypeRadioButtons() {
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
                  width: 100.0,
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
                  width: 100.0,
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
                  width: 100.0,
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

    Widget _buildEventTicketRadioButtons() {
      return Container(
        padding: EdgeInsets.symmetric(
          vertical: 16.0,
        ),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                CustomColorButton(
                  height: 30.0,
                  width: 150.0,
                  hPadding: 0,
                  text: 'Yes',
                  textColor: eventTicketRadioValue == 0 ? Colors.white : Colors.black,
                  backgroundColor: eventTicketRadioValue == 0 ? FlatColors.webblenRed : FlatColors.textFieldGray,
                  onPressed: () {
                    eventTicketRadioValue = 0;
                    setState(() {});
                  },
                ),
                CustomColorButton(
                  height: 30.0,
                  width: 150.0,
                  hPadding: 0,
                  text: 'No',
                  textColor: eventTicketRadioValue == 1 ? Colors.white : Colors.black,
                  backgroundColor: eventTicketRadioValue == 1 ? FlatColors.webblenRed : FlatColors.textFieldGray,
                  onPressed: () {
                    eventTicketRadioValue = 1;
                    setState(() {});
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget _buildSearchAutoComplete() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
            ),
            child: Fonts().textW500(
                newEvent.address == null || newEvent.address.isEmpty ? "Set Address" : "${newEvent.address}", 16.0, FlatColors.darkGray, TextAlign.center),
          ),
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
//              displayPrediction(p, homeScaffoldKey.currentState);
                },
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0,
                  ),
                  child: Text(
                    "Search Address",
                  ),
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
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0,
                  ),
                  child: Text(
                    "Current Location",
                  ),
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
      this.validateEventDetails,
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
      this.validateTicketStatus,
    );
    final formButton4 = NewEventFormButton(
      "Next",
      FlatColors.blackPearl,
      Colors.white,
      this.validateTicketPage,
    );
    final formButton5 = NewEventFormButton(
      "Next",
      FlatColors.blackPearl,
      Colors.white,
      this.validateAddress,
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
    final addressBackButton = FlatBackButton(
      "Back",
      FlatColors.blackPearl,
      Colors.white,
      this.addressButtonBackAction,
    );

    Widget buildTicketForm() {
      return GestureDetector(
        onTap: () => FocusNode().unfocus(),
        child: Container(
            height: MediaQuery.of(context).size.height * 0.50,
            width: 150,
            child: Form(
              key: ticketFormKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  TextFormField(
                    textAlign: TextAlign.center,
                    initialValue: ticketName == null ? null : ticketName,
                    decoration: InputDecoration(
                      hintText: "Ticket Name",
                      border: InputBorder.none,
                    ),
                    onSaved: (val) => ticketName = val,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontFamily: "Helvetica Neue",
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(25),
                      BlacklistingTextInputFormatter(
                        RegExp(
                          "[\\-|\\#|\\[|\\]|\\%|\\^|\\*|\\+|\\=|\\_|\\~|\\<|\\>|\\,|\\@|\\(|\\)|\\'|\\{|\\}|\\.]",
                        ),
                      ),
                    ],
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                  ),
                  Divider(color: Colors.black, thickness: 0.2),
                  SizedBox(height: 8.0),
                  Fonts().textW600("Quantity Available", 18.0, Colors.black, TextAlign.left),
                  TextFormField(
                    textAlign: TextAlign.left,
                    initialValue: ticketQuantity == null ? null : ticketQuantity,
                    decoration: InputDecoration(
                      hintText: "100",
                      border: InputBorder.none,
                    ),
                    onSaved: (val) => ticketQuantity = val,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: "Helvetica Neue",
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                  ),
                  Divider(color: Colors.black, thickness: 0.2),
                  SizedBox(height: 8.0),
                  Fonts().textW600("Ticket Price (USD)", 18.0, Colors.black, TextAlign.left),
                  TextFormField(
                    controller: moneyMaskedTextController,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                    //initialValue: ticketPrice == null ? null : ticketPrice,
                    decoration: InputDecoration(
                      hintText: "9.99",
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      double p = double.parse(val.substring(1)) * 10.0;
                      ticketPrice = "\$${p.toStringAsFixed(2)}";
                    },
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: "Helvetica Neue",
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                  ),
                  NewEventFormButton(
                    "Create Ticket",
                    FlatColors.blackPearl,
                    Colors.white,
                    this.validateTicketForm,
                  ),
                ],
              ),
            )),
      );
    }

    Widget buildAdditionalFeeForm() {
      return GestureDetector(
        onTap: () => FocusNode().unfocus(),
        child: Container(
            height: MediaQuery.of(context).size.height * 0.50,
            width: 150,
            child: Form(
              key: feeFormKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  TextFormField(
                    initialValue: feeName,
                    decoration: InputDecoration(
                      hintText: "Fee Description",
                      border: InputBorder.none,
                    ),
                    onSaved: (val) => feeName = val,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: "Helvetica Neue",
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    autocorrect: false,
                  ),
                  Divider(color: Colors.black, thickness: 0.2),
                  SizedBox(height: 8.0),
                  Fonts().textW600("Fee Amount", 18.0, Colors.black, TextAlign.left),
                  TextFormField(
                    controller: moneyMaskedTextController,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.numberWithOptions(signed: false, decimal: true),
                    initialValue: null,
                    decoration: InputDecoration(
                      hintText: "1.99",
                      border: InputBorder.none,
                    ),
                    onChanged: (val) {
                      double p = double.parse(val.substring(1)) * 10.0;
                      feeAmount = "\$${p.toStringAsFixed(2)}";
                    },
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: "Helvetica Neue",
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                  ),
                  NewEventFormButton(
                    "Add Fee",
                    FlatColors.blackPearl,
                    Colors.white,
                    this.validateFeeForm,
                  ),
                ],
              ),
            )),
      );
    }

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
              Divider(
                indent: 8.0,
                endIndent: 8.0,
              ),
              _buildEventDescriptionField(),
              Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  top: 8.0,
                  right: 16.0,
                ),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0,
                  ),
                  child: Fonts().textW700(
                    "Event Type",
                    18.0,
                    FlatColors.darkGray,
                    TextAlign.left,
                  ),
                ),
              ),
              _buildEventTypeRadioButtons(),
              Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  top: 8.0,
                  right: 16.0,
                ),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0,
                  ),
                  child: Fonts().textW700(
                    "Date",
                    18.0,
                    FlatColors.darkGray,
                    TextAlign.left,
                  ),
                ),
              ),
              _buildStartDateField(),
              _buildEndDateField(),
              Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  top: 24.0,
                  right: 16.0,
                ),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0,
                  ),
                  child: Fonts().textW700(
                    "External Links (Optional)",
                    18.0,
                    FlatColors.darkGray,
                    TextAlign.left,
                  ),
                ),
              ),
              _buildFBUrlField(),
              _buildTwitterUrlField(),
              _buildWebsiteUrlField(),
              formButton1,
            ],
          ),
        ),
      ),
    );

    //**Tags Page
    final eventFormPage2 = Container(
      child: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 32.0),
              _buildTagsField(),
              SizedBox(height: 32.0),
              formButton2,
              backButton,
            ],
          ),
        ],
      ),
    );

    //**Ask About Tickets Page
    final eventFormPage3 = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Fonts().textW700(
                  "Will This Event Have Tickets?",
                  18.0,
                  FlatColors.darkGray,
                  TextAlign.center,
                ),
                _buildEventTicketRadioButtons()
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                formButton3,
                backButton,
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );

    //**Tickets Page
    final eventFormPage4 = Container(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 16.0),
                Fonts().textW500("Event Tickets:", 18.0, Colors.black, TextAlign.left),
                SizedBox(height: 4.0),
                ticketAndFeeListBuilder(true, false),
                GestureDetector(
                  onTap: () => ShowAlertDialogService().showFormDialog(context, buildTicketForm()),
                  child: Fonts().textW400("Add New Ticket", 14.0, FlatColors.electronBlue, TextAlign.left),
                ),
                SizedBox(height: 32.0),
                Fonts().textW500("Fees:", 18.0, Colors.black, TextAlign.left),
                SizedBox(height: 4.0),
                ticketAndFeeListBuilder(false, false),
                GestureDetector(
                  onTap: () => ShowAlertDialogService().showFormDialog(context, buildAdditionalFeeForm()),
                  child: Fonts().textW400("Add Additional Fee", 14.0, FlatColors.electronBlue, TextAlign.left),
                ),
                SizedBox(height: 64.0),
                formButton4,
                backButton,
              ],
            ),
          ),
        ],
      ),
    );

    // Address Page
    final eventFormPage5 = Container(
      child: ListView(
        children: <Widget>[
          Form(
            key: page7FormKey,
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
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: 1.0,
                      ),
                      child: Fonts().textW500(
                        'Notify Users Within: ',
                        16.0,
                        FlatColors.darkGray,
                        TextAlign.left,
                      ),
                    ),
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: 1.0,
                      ),
                      child: Fonts().textW400(
                        '${(newEvent.radius.toStringAsFixed(2))} Miles ',
                        16.0,
                        FlatColors.darkGray,
                        TextAlign.left,
                      ),
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
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: 1.0,
                      ),
                      child: Fonts().textW700(
                        'Estimated Reach: ',
                        16.0,
                        FlatColors.darkGray,
                        TextAlign.left,
                      ),
                    ),
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: 1.0,
                      ),
                      child: Fonts().textW400(
                        '${(newEvent.radius.round() * 13)}',
                        16.0,
                        FlatColors.darkGray,
                        TextAlign.left,
                      ),
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
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: 1.0,
                      ),
                      child: Fonts().textW700(
                        'Total Cost: ',
                        16.0,
                        FlatColors.darkGray,
                        TextAlign.left,
                      ),
                    ),
                    MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: 1.0,
                      ),
                      child: Fonts().textW400(
                        'FREE',
                        16.0,
                        FlatColors.darkGray,
                        TextAlign.left,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30.0,
                ),
                formButton5,
                addressBackButton,
              ],
            ),
          ),
        ],
      ),
    );

    //FINAL SUBMISSION PAGE
    final eventFormPage6 = ListView(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.width,
          child: widget.eventToEdit != null
              ? CachedNetworkImage(
                  imageUrl: newEvent.imageURL,
                  fit: BoxFit.contain,
                )
              : eventImage != null
                  ? Image.file(
                      eventImage,
                      fit: BoxFit.contain,
                    )
                  : Container(),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Fonts().textW700(
                'Details',
                24.0,
                Colors.black,
                TextAlign.left,
              ),
              Fonts().textW500(
                newEvent.description == null ? "" : newEvent.description,
                16.0,
                Colors.black,
                TextAlign.left,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: 16.0,
          ),
          child: Fonts().textW500(
            'Additional Details',
            18.0,
            Colors.black,
            TextAlign.left,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: 8.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.directions,
                    size: 24.0,
                    color: Colors.black,
                  ),
                ],
              ),
              SizedBox(
                width: 8.0,
              ),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 4.0,
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: Fonts().textW400(
                      newEvent.address == null ? "" : '${newEvent.address.replaceAll(', USA', '').replaceAll(', United States', '')}',
                      16.0,
                      Colors.black,
                      TextAlign.left,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 18.0,
            top: 8.0,
          ),
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.calendar,
                    size: 20.0,
                    color: Colors.black,
                  ),
                ],
              ),
              SizedBox(
                width: 8.0,
              ),
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 4.0,
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: Fonts().textW400(
                      newEvent.startDateInMilliseconds == null
                          ? ""
                          : formatter.format(
                              DateTime.fromMillisecondsSinceEpoch(newEvent.startDateInMilliseconds),
                            ),
                      16.0,
                      Colors.black,
                      TextAlign.left,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: 32.0,
          ),
          child: Fonts().textW500(
            'Tickets',
            18.0,
            Colors.black,
            TextAlign.left,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: 8.0,
          ),
          child: eventTickets.isNotEmpty ? ticketAndFeeListBuilder(true, true) : Container(),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: 32.0,
          ),
          child: Fonts().textW500(
            'Additional Fees',
            18.0,
            Colors.black,
            TextAlign.left,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            top: 8.0,
          ),
          child: eventFees.isNotEmpty ? ticketAndFeeListBuilder(false, true) : Container(),
        ),
        submitButton,
        backButton,
      ],
    );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 1.0,
      ),
      child: Scaffold(
        appBar: WebblenAppBar().newEventAppBar(
            context,
            widget.eventToEdit != null ? 'Editing Event' : 'New Event',
            widget.eventToEdit != null
                ? widget.eventToEdit.communityAreaName + "/" + widget.eventToEdit.communityName
                : widget.community.areaName + "/" + widget.community.name,
            'Cancel Adding a New Event?', () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
            isTyping
                ? GestureDetector(
                    onTap: () => dismissKeyboard(),
                    child: Container(
                      margin: EdgeInsets.only(right: 16.0, top: 12.0),
                      child: Fonts().textW700('Done', 18.0, Colors.blueAccent, TextAlign.right),
                    ))
                : Container()),
        key: homeScaffoldKey,
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            eventFormPage1,
            eventFormPage2,
            eventFormPage3,
            eventFormPage4,
            eventFormPage5,
            eventFormPage6,
          ],
        ),
      ),
    );
  }
}

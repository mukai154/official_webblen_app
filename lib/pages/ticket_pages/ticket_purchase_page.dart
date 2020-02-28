import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:intl/intl.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:stripe_sdk/stripe_sdk_ui.dart';
import 'package:webblen/firebase_data/event_data.dart';
import 'package:webblen/firebase_data/stripe_data.dart';
import 'package:webblen/models/event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/strings.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

class TicketPurchasePage extends StatefulWidget {
  final WebblenUser currentUser;
  final Event event;
  final List<Map<String, dynamic>> ticketsToPurchase;
  final List eventFees;

  TicketPurchasePage({
    this.currentUser,
    this.event,
    this.ticketsToPurchase,
    this.eventFees,
  });

  @override
  State<StatefulWidget> createState() {
    return _TicketPurchasePageState();
  }
}

class _TicketPurchasePageState extends State<TicketPurchasePage> {
  bool isLoading = true;
  //Keys
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ticketPaymentFormKey = GlobalKey<FormState>();

  //Event Info
  WebblenUser eventHost;
  DateFormat formatter = DateFormat('MMM dd, yyyy h:mm a');

  //Customer Info
  String firstName;
  String lastName;
  String emailAddress;
  String areaCode;

  //payments
  double salesTax = 0.00;
  double userPlatformFees = 0.00;
  double totalPlatformFees;
  int numberOfTickets = 0;
  double chargeAmount = 0.00;

  var cardNumberMask = MaskedTextController(mask: '0000 0000 0000 0000');
  var expiryDateMask = MaskedTextController(mask: 'XX/XX');
  bool cvcFocused = false;
  String stripeUID;
  String cardNumber = "";
  String expiryDate = "MM/YY";
  int expMonth = 1;
  int expYear = 2020;
  String cardHolderName = "";
  String cvcNumber = "";

  cvcFocus(bool focus) {
    if (focus) {
      cvcFocused = true;
    } else {
      cvcFocused = false;
    }
    setState(() {});
  }

  initializeAndCalculateTotals() {
    widget.ticketsToPurchase.forEach((ticket) {
      print(ticket);
      int ticketQty = ticket['qty'];
      double ticketPrice = double.parse(ticket['ticketPrice'].toString().substring(1));
      double ticketCharge = ticketPrice * ticketQty;
      numberOfTickets += ticketQty;
      chargeAmount += ticketCharge;
    });
    if (widget.eventFees != null && widget.eventFees.isNotEmpty) {
      widget.eventFees.forEach((fee) {
        double feeCharge = double.parse(fee['feeAmount'].toString().substring(1));

        chargeAmount += feeCharge * numberOfTickets;
      });
    }
    userPlatformFees = 0.49 * numberOfTickets;
    salesTax = (userPlatformFees + chargeAmount) * 0.06;
    chargeAmount += userPlatformFees + salesTax + 0.49;
    isLoading = false;
    setState(() {});
  }

  void showFormAlert(String alertDesc) {
    ScaffoldState scaffoldState = scaffoldKey.currentState;
    scaffoldState.showSnackBar(
      SnackBar(
        content: Text(alertDesc),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  validateAndSubmit() {
    ShowAlertDialogService().showLoadingDialog(context);
    ticketPaymentFormKey.currentState.save();
    cardNumber = cardNumber.replaceAll(" ", "");
    if (firstName == null || firstName.isEmpty) {
      Navigator.of(context).pop();
      showFormAlert("First Name Cannot be Empty");
    } else if (lastName == null || lastName.isEmpty) {
      Navigator.of(context).pop();
      showFormAlert("Last Name Cannot be Empty");
    } else if (emailAddress == null || emailAddress.isEmpty) {
      Navigator.of(context).pop();
      showFormAlert("Email Address Cannot be Empty");
    } else if (!Strings().isEmailValid(emailAddress)) {
      Navigator.of(context).pop();
      showFormAlert("Please Provide a Valid Email Address");
    } else if (cardNumber == null || cardNumber.length != 16) {
      Navigator.of(context).pop();
      showFormAlert("Invalid Card Number");
    } else if (expMonth < 1 || expMonth > 12) {
      Navigator.of(context).pop();
      showFormAlert("Invalid Expiry Month");
    } else if (expYear < DateTime.now().year) {
      Navigator.of(context).pop();
      showFormAlert("Invalid Expiry Year");
    } else if (cardHolderName == null || cardHolderName.isEmpty) {
      Navigator.of(context).pop();
      showFormAlert("Name Cannot Be Empty");
    } else if (cvcNumber == null || cvcNumber.length != 3) {
      Navigator.of(context).pop();
      showFormAlert("Invalid CVC Code");
    } else {
      submitPayment();
    }
  }

  void submitPayment() {
    totalPlatformFees = salesTax + userPlatformFees;
    StripeCard card = StripeCard(number: cardNumber, expMonth: expMonth, expYear: expYear, cvc: cvcNumber, name: cardHolderName);
    StripeApi.instance.createPaymentMethodFromCard(card).then((res) {
      StripeDataService()
          .submitTicketPurchaseToStripe(widget.currentUser.uid, chargeAmount, totalPlatformFees, numberOfTickets, widget.ticketsToPurchase,
              widget.event.eventKey, widget.event.authorUid, cardNumber, expMonth, expYear, cvcNumber, cardHolderName, emailAddress)
          .then((res) {
        Navigator.of(context).pop();
        if (res == 'passed') {
          completePurchase();
        } else {
          ShowAlertDialogService().showFailureDialog(context, "Payment Failed", "There was an Issue Processing Your Card.");
        }
      });
    }).catchError((e) {
      Navigator.of(context).pop();
      String error = e.toString();
      showFormAlert(error);
    });
  }

  void completePurchase() {
    EventDataService().completeTicketPurchase(widget.currentUser.uid, widget.ticketsToPurchase, widget.event).then((res) {
      ShowAlertDialogService().showActionSuccessDialog(context, "Purchase Successful!", "Your Tickets Can Be Found in Your Account", () {
        Navigator.of(context).pop();
        PageTransitionService(context: context).returnToRootPage();
      });
    });
  }

  Widget ticketListBuilder() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.ticketsToPurchase.length,
        itemBuilder: (BuildContext context, int index) {
          double ticketPrice = double.parse(widget.ticketsToPurchase[index]['ticketPrice'].toString().substring(1));
          double ticketCharge = ticketPrice * widget.ticketsToPurchase[index]['qty'];
          return widget.ticketsToPurchase[index]['qty'] > 0
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  height: 40.0,
                  //width: MediaQuery.of(context).size.width * 0.60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        //width: MediaQuery.of(context).size.width * 0.60,
                        child: Fonts().textW400(
                          "${widget.ticketsToPurchase[index]["ticketName"]} (${widget.ticketsToPurchase[index]["qty"]})",
                          16.0,
                          Colors.black,
                          TextAlign.left,
                        ),
                      ),
                      Container(
                        //width: 95,
                        child: Fonts().textW400(
                          "+ \$${ticketCharge.toStringAsFixed(2)}",
                          16.0,
                          Colors.black,
                          TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                )
              : Container();
        });
  }

  Widget eventFeeBuilder() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.eventFees.length,
        itemBuilder: (BuildContext context, int index) {
          String feeName = widget.eventFees[index]['feeName'];
          double feeCharge = double.parse(widget.eventFees[index]['feeAmount'].toString().substring(1));
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            height: 40.0,
            //width: MediaQuery.of(context).size.width * 0.60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  //width: MediaQuery.of(context).size.width * 0.60,
                  child: Fonts().textW400(
                    numberOfTickets == 1 ? "$feeName (1 ticket)" : "$feeName ($numberOfTickets tickets)",
                    16.0,
                    Colors.black,
                    TextAlign.left,
                  ),
                ),
                Container(
                  //width: 95,
                  child: Fonts().textW400(
                    "+ \$${(feeCharge * numberOfTickets).toStringAsFixed(2)}",
                    16.0,
                    Colors.black,
                    TextAlign.left,
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget platformFee() {
    return Container(
      height: 40.0,
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      //width: MediaQuery.of(context).size.width * 0.60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            //width: MediaQuery.of(context).size.width * 0.60,
            child: Fonts().textW400(
              "Additional Fees & Sales Tax",
              16.0,
              Colors.black,
              TextAlign.left,
            ),
          ),
          Container(
            //width: 95,
            child: Fonts().textW400(
              "+ \$${(salesTax + userPlatformFees + 0.49).toStringAsFixed(2)}",
              16.0,
              Colors.black,
              TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget formSectionHeader(String val) {
    return Container(
      margin: EdgeInsets.only(
        top: 16.0,
        left: 8.0,
        right: 16.0,
        //bottom: 4.0,
      ),
      child: Fonts().textW700(
        val,
        18.0,
        Colors.black,
        TextAlign.left,
      ),
    );
  }

  Widget formFieldHeader(String val) {
    return Container(
      margin: EdgeInsets.only(
        top: 8.0,
        left: 8.0,
        right: 16.0,
        bottom: 4.0,
      ),
      child: Fonts().textW500(
        val,
        14.0,
        Colors.black54,
        TextAlign.left,
      ),
    );
  }

  Widget stringFormFieldFor(String val) {
    return Container(
      height: 35.0,
      margin: EdgeInsets.only(
        top: 4.0,
        left: 6.0,
        right: 8.0,
        bottom: 8.0,
      ),
      decoration: BoxDecoration(
        color: FlatColors.iosOffWhite,
        border: Border.all(width: 1.0, color: Colors.black12),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: 8.0, bottom: 15.0),
          border: InputBorder.none,
        ),
        onSaved: (input) {
          if (val == 'firstName') {
            firstName = input;
          } else if (val == 'lastName') {
            lastName = input;
          } else if (val == 'email') {
            emailAddress = input;
          }
          setState(() {});
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontFamily: "Helvetica Neue",
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    StripeApi.init("pk_test_gYHQOvqAIkPEMVGQRehk3nj4009Kfodta1");
    initializeAndCalculateTotals();
  }

  @override
  Widget build(BuildContext context) {
    final cardNumberField = Container(
      margin: EdgeInsets.only(
        top: 4.0,
        left: 32.0,
        right: 32.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: FlatColors.iosOffWhite,
        border: Border.all(width: 1.0, color: Colors.black12),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: TextFormField(
        controller: cardNumberMask,
        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
        decoration: InputDecoration(
          hintText: "XXXX XXXX XXXX XXXX",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          cvcFocused = false;
          cardNumber = val;
          setState(() {});
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontFamily: "Helvetica Neue",
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          LengthLimitingTextInputFormatter(19),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );

    final expiryMonthField = Container(
      width: MediaQuery.of(context).size.width * 0.5 - 64,
      margin: EdgeInsets.only(
        top: 4.0,
        left: 32.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: FlatColors.iosOffWhite,
        border: Border.all(width: 1.0, color: Colors.black12),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "01",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          cvcFocused = false;
          expMonth = int.parse(val);
          setState(() {});
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontFamily: "Helvetica Neue",
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );

    final expiryYearField = Container(
      width: MediaQuery.of(context).size.width * 0.5 - 64,
      margin: EdgeInsets.only(
        top: 4.0,
        left: 32.0,
        right: 32.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: FlatColors.iosOffWhite,
        border: Border.all(width: 1.0, color: Colors.black12),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "2024",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          cvcFocused = false;
          expYear = int.parse(val);
          setState(() {});
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontFamily: "Helvetica Neue",
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(4),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );

    final cardHolderNameField = Container(
      margin: EdgeInsets.only(
        top: 4.0,
        left: 32.0,
        right: 32.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: FlatColors.iosOffWhite,
        border: Border.all(width: 1.0, color: Colors.black12),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "Your Name",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          cvcFocused = false;
          cardHolderName = val;
          setState(() {});
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontFamily: "Helvetica Neue",
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );

    Widget cvcField = Container(
      margin: EdgeInsets.only(
        top: 4.0,
        left: 32.0,
        right: 32.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: FlatColors.iosOffWhite,
        border: Border.all(width: 1.0, color: Colors.black12),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "XXX",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          cvcFocused = true;
          cvcNumber = val;
          setState(() {});
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontFamily: "Helvetica Neue",
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: WebblenAppBar().basicAppBar(
        "Purchase Tickets",
        context,
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? CustomLinearProgress(progressBarColor: FlatColors.webblenRed)
            : ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Form(
                      key: ticketPaymentFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            height: 16.0,
                          ),
                          Fonts().textW700(widget.event.title, 30.0, Colors.black, TextAlign.left),
                          SizedBox(
                            height: 4.0,
                          ),
                          Fonts().textW300(
                            formatter.format(
                              DateTime.fromMillisecondsSinceEpoch(widget.event.startDateInMilliseconds),
                            ),
                            14.0,
                            Colors.black,
                            TextAlign.left,
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          ticketListBuilder(),
                          widget.eventFees != null && widget.eventFees.isNotEmpty ? eventFeeBuilder() : Container(),
                          platformFee(),
                          Container(
                            height: 32.0,
                            decoration: BoxDecoration(
                              color: FlatColors.iosOffWhite,
                              border: Border.all(
                                color: Colors.black26,
                                width: 0.8,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: Fonts().textW500(
                                    "Total: \$${chargeAmount.toStringAsFixed(2)}",
                                    18.0,
                                    Colors.black,
                                    TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          formSectionHeader("Your Info"),
                          formFieldHeader("First Name"),
                          stringFormFieldFor("firstName"),
                          formFieldHeader("Last Name"),
                          stringFormFieldFor("lastName"),
                          formFieldHeader("Email Address"),
                          stringFormFieldFor("email"),
                          formSectionHeader("Payment Info"),
                          CreditCardWidget(
                            cardNumber: cardNumber,
                            expiryDate: expMonth <= 9 ? "0$expMonth/$expYear" : "$expMonth/$expYear",
                            cardHolderName: cardHolderName,
                            cvvCode: cvcNumber,
                            showBackView: cvcFocused,
                            cardbgColor: FlatColors.webblenRed,
                            height: 175,
                            textStyle: TextStyle(
                              color: cvcFocused ? Colors.black : Colors.white,
                              fontSize: 18.0,
                              fontFamily: "Helvetica Neue",
                              fontWeight: FontWeight.w400,
                            ),
                            width: MediaQuery.of(context).size.width,
                            animationDuration: Duration(milliseconds: 1000),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 32.0,
                              right: 32.0,
                              bottom: 4.0,
                            ),
                            child: Fonts().textW700(
                              "Card Number",
                              16.0,
                              Colors.black,
                              TextAlign.left,
                            ),
                          ),
                          cardNumberField,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 32.0,
                                      right: 16.0,
                                      bottom: 4.0,
                                    ),
                                    child: Fonts().textW700(
                                      "Expiry Month",
                                      16.0,
                                      Colors.black,
                                      TextAlign.left,
                                    ),
                                  ),
                                  expiryMonthField,
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 32.0,
                                      right: 32.0,
                                      bottom: 4.0,
                                    ),
                                    child: Fonts().textW700(
                                      "Expiry Year",
                                      16.0,
                                      Colors.black,
                                      TextAlign.left,
                                    ),
                                  ),
                                  expiryYearField,
                                ],
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 32.0,
                              right: 32.0,
                              bottom: 4.0,
                            ),
                            child: Fonts().textW700(
                              "Card Holder Name",
                              16.0,
                              Colors.black,
                              TextAlign.left,
                            ),
                          ),
                          cardHolderNameField,
                          Container(
                            margin: EdgeInsets.only(
                              left: 32.0,
                              right: 32.0,
                              bottom: 4.0,
                            ),
                            child: Fonts().textW700(
                              "CVC",
                              16.0,
                              Colors.black,
                              TextAlign.left,
                            ),
                          ),
                          cvcField,
                        ],
                      ),
                    ),
                  )
                ],
              ),
      ),
      bottomNavigationBar: Container(
        height: 80.0,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: FlatColors.textFieldGray,
              width: 1.5,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomColorButton(
                text: "Order Now",
                textSize: 14.0,
                textColor: chargeAmount == 0 ? Colors.black26 : Colors.white,
                backgroundColor: chargeAmount == 0 ? FlatColors.textFieldGray : FlatColors.darkMountainGreen,
                height: 40.0,
                width: MediaQuery.of(context).size.width * 0.9,
                onPressed: () => validateAndSubmit(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

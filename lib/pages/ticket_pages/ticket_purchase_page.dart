import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:stripe_sdk/stripe_sdk.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/firebase/data/platform_data.dart';
import 'package:webblen/firebase/data/ticket_data.dart';
import 'package:webblen/models/ticket_distro.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/stripe/stripe_payment.dart';
import 'package:webblen/services_general/service_page_transitions.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/strings.dart';
import 'package:webblen/widgets/common/alerts/custom_alerts.dart';
import 'package:webblen/widgets/common/app_bar/custom_app_bar.dart';
import 'package:webblen/widgets/common/containers/text_field_container.dart';
import 'package:webblen/widgets/common/text/custom_text.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';
import 'package:webblen/widgets/widgets_common/common_progress.dart';

class TicketPurchasePage extends StatefulWidget {
  final WebblenUser currentUser;
  final WebblenEvent event;
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
  bool isLoading = false;
  bool hasAccount = false;
  bool isLoggedIn = false;
  bool acceptedTermsAndConditions = false;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final authFormKey = GlobalKey<FormState>();
  final ticketPaymentFormKey = GlobalKey<FormState>();
  final emailFormKey = GlobalKey<FormState>();
  final discountCodeFormKey = GlobalKey<FormState>();

  //Event Info
  WebblenUser eventHost;
  TicketDistro ticketDistro;

  //payments
  int numOfTicketsToPurchase = 0;
  double ticketRate;
  double taxRate;
  double ticketCharge = 0.00;
  double ticketFeeCharge = 0.00;
  double customFeeCharge = 0.00;
  double taxCharge = 0.00;
  double chargeAmount = 0.0;
  double discountAmount = 0.0;
  String discountCodeDescription;
  List<String> appliedDiscountCodes = [];
  String discountCodeStatus;
  String discountCode;
  List<String> ticketEmails = [];

  //Customer Info
  String firstName;
  String lastName;
  String emailAddress;
  String areaCode;

  //Card Info
  String cardType;
  String paymentFormError;
  var cardNumberMask = MaskedTextController(mask: '0000 0000 0000 0000');
  var expiryDateMask = MaskedTextController(mask: 'XX/XX');
  bool cvcFocused = false;
  String stripeUID;
  String cardNumber = "";
  String expiryDate = "MM/YY";
  int expMonth = DateTime.now().month;
  int expYear = DateTime.now().year;
  String cardHolderName = "";
  String cvcNumber = "";
  bool paymentButtonDisabled = false;

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

  Widget formSectionHeader(String val) {
    return Container(
      margin: EdgeInsets.only(
        top: 16.0,
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
        bottom: 4.0,
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

  Widget emailOnlyFormField() {
    return Form(
      key: emailFormKey,
      child: Container(
        height: 35.0,
        margin: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
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
            emailAddress = input;
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
      ),
    );
  }

  Widget ticketChargeList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
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
                      child: CustomText(
                        context: context,
                        text: "${widget.ticketsToPurchase[index]["ticketName"]} (${widget.ticketsToPurchase[index]["qty"]})",
                        textColor: Colors.black,
                        textAlign: TextAlign.left,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      //width: 95,
                      child: CustomText(
                        context: context,
                        text: "+ \$${ticketCharge.toStringAsFixed(2)}",
                        textColor: Colors.black,
                        textAlign: TextAlign.left,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : Container();
      },
    );
  }

  Widget additionalFeesAndSalesTax() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      height: 40.0,
      //width: MediaQuery.of(context).size.width * 0.60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            //width: MediaQuery.of(context).size.width * 0.60,
            child: CustomText(
              context: context,
              text: "Additional Fees & Sales Tax",
              textColor: Colors.black,
              textAlign: TextAlign.left,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            //width: 95,
            child: CustomText(
              context: context,
              text: "+ \$${(ticketFeeCharge + taxCharge).toStringAsFixed(2)}",
              textColor: Colors.black,
              textAlign: TextAlign.left,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget discountsInfo() {
    return discountAmount == 0.0
        ? Container()
        : Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            height: 40.0,
            //width: MediaQuery.of(context).size.width * 0.60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  //width: MediaQuery.of(context).size.width * 0.60,
                  child: CustomText(
                    context: context,
                    text: "Discount ($discountCodeDescription)",
                    textColor: Colors.black,
                    textAlign: TextAlign.left,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  //width: 95,
                  child: CustomText(
                    context: context,
                    text: "- \$${discountAmount.toStringAsFixed(2)}",
                    textColor: Colors.red,
                    textAlign: TextAlign.left,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
  }

  Widget discountCodeAlert() {
    return discountCode == null
        ? Container()
        : discountCodeStatus == 'duplicate'
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                child: CustomText(
                  context: context,
                  text: "This Code Has Already Been Used",
                  textColor: Colors.red,
                  textAlign: TextAlign.left,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              )
            : discountCodeStatus == 'passed'
                ? Container(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    child: CustomText(
                      context: context,
                      text: "Discount Applied Successfully",
                      textColor: Colors.green,
                      textAlign: TextAlign.left,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : discountCodeStatus == 'multiple'
                    ? Container(
                        margin: EdgeInsets.symmetric(vertical: 4.0),
                        child: CustomText(
                          context: context,
                          text: "Only One Code Can Be Used at a Time",
                          textColor: Colors.red,
                          textAlign: TextAlign.left,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : discountCodeStatus == 'expired'
                        ? Container(
                            margin: EdgeInsets.symmetric(vertical: 4.0),
                            child: CustomText(
                              context: context,
                              text: "Code is No Longer Valid",
                              textColor: Colors.red,
                              textAlign: TextAlign.left,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.symmetric(vertical: 4.0),
                            child: CustomText(
                              context: context,
                              text: "Invalid Code",
                              textColor: Colors.red,
                              textAlign: TextAlign.left,
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                            ),
                          );
  }

  Widget discountCodeRow() {
    return Container(
      child: Form(
        key: discountCodeFormKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextFieldContainer(
              height: 35,
              width: 200.0, //screenSize.isMobile ? 60 : screenSize.isTablet ? 75 : 100,
              child: TextFormField(
                cursorColor: Colors.black,
                onSaved: (value) => discountCode = value.trim(),
                decoration: InputDecoration(
                  hintText: "Enter Discount Code",
                  border: InputBorder.none,
                ),
              ),
            ),
            DialogButton(
              height: 35,
              width: 100.0,
              onPressed: () => applyDiscountCode(),
              color: CustomColors.darkGray,
              child: CustomText(
                context: context,
                text: "Apply",
                textColor: Colors.white,
                textAlign: TextAlign.left,
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget cardNumberField() {
    return Container(
      margin: EdgeInsets.only(
        top: 4.0,
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
  }

  Widget expiryMonthField() {
    return TextFieldContainer(
      width: 100,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "01",
          contentPadding: EdgeInsets.only(
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
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
  }

  Widget expiryYearField() {
    return TextFieldContainer(
      width: 100,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "2024",
          contentPadding: EdgeInsets.only(
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
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
  }

  Widget cardHolderNameField() {
    return Container(
      margin: EdgeInsets.only(
        top: 4.0,
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
  }

  Widget cvcField() {
    return TextFieldContainer(
      width: 100,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "XXX",
          contentPadding: EdgeInsets.only(
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
  }

  Widget acceptTermsAndConditionsField() {
    return Container(
      child: Row(
        children: <Widget>[
          Checkbox(
            onChanged: (val) => acceptTermsAndConditions(val),
            value: acceptedTermsAndConditions,
          ),
          GestureDetector(
            onTap: () => acceptTermsAndConditions(null),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'By purchasing, I understand & agree to the ',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: 'Terms and Conditions ',
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  TextSpan(
                    text: 'and that my information will be used as described on this page and in the ',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: 'Privacy Policy. ',
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  acceptTermsAndConditions(bool val) {
    if (val == null) {
      if (acceptedTermsAndConditions) {
        acceptedTermsAndConditions = false;
      } else {
        acceptedTermsAndConditions = true;
      }
    } else {
      acceptedTermsAndConditions = val;
    }
    setState(() {});
  }

  cvcFocus(bool focus) {
    if (focus) {
      cvcFocused = true;
    } else {
      cvcFocused = false;
    }
    setState(() {});
  }

  calculateChargeTotals() {
    widget.ticketsToPurchase.forEach((ticket) {
      double ticketPrice = double.parse(ticket['ticketPrice'].toString().substring(1));
      double charge = ticketPrice * ticket['qty'];
      numOfTicketsToPurchase += ticket['qty'];
      ticketCharge += charge;
    });
    ticketFeeCharge = numOfTicketsToPurchase * ticketRate;
    taxCharge = (ticketCharge + ticketFeeCharge) * taxRate;
    chargeAmount = ticketCharge + ticketFeeCharge + taxCharge + customFeeCharge;
    setState(() {});
  }

  applyDiscountCode() async {
    FormState discountForm = discountCodeFormKey.currentState;
    discountForm.save();
    int discountCodeIndex = ticketDistro.discountCodes.indexWhere((code) => code['discountCodeName'] == discountCode.trim());
    if (discountCodeIndex == null || discountCodeIndex == -1) {
      discountCodeStatus = 'failed';
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop();
    } else {
      Map<String, dynamic> code = ticketDistro.discountCodes[discountCodeIndex];
      if (appliedDiscountCodes.contains(discountCode)) {
        discountCodeStatus = 'duplicate';
      } else if (appliedDiscountCodes.isNotEmpty) {
        discountCodeStatus = 'multiple';
      } else if (code['discountCodeQuantity'] == '0') {
        discountCodeStatus = 'expired';
      } else {
        if (discountCodeIndex >= 0) {
          double discountPercent = double.parse(code['discountCodePercentage']) * 0.01;
          if (numOfTicketsToPurchase > 1) {
            Map<String, dynamic> ticket = widget.ticketsToPurchase.first;
            double ticketPrice = double.parse(ticket['ticketPrice'].replaceAll("\$", ""));
            discountAmount = ticketPrice * discountPercent;
            discountCodeDescription = "1 Ticket ${(discountPercent * 100).toInt().toString()}% Off";
            chargeAmount = chargeAmount - discountAmount;
          } else {
            discountAmount = chargeAmount * discountPercent;
            discountCodeDescription = "${(discountPercent * 100).toInt().toString()}% Off";
            chargeAmount = chargeAmount - discountAmount;
            if (chargeAmount == 0) {
              paymentButtonDisabled = false;
            } else {
              paymentButtonDisabled = true;
            }
          }
          List discountCodes = ticketDistro.discountCodes.toList(growable: true);
          int numberOfDiscountsAvailable = int.parse(code['discountCodeQuantity']);
          numberOfDiscountsAvailable -= 1;
          code['discountCodeQuantity'] = numberOfDiscountsAvailable.toString();
          discountCodes[discountCodeIndex] = code;
          ticketDistro.discountCodes = discountCodes;
          appliedDiscountCodes.add(discountCode);
          discountCodeStatus = 'passed';
        } else {
          discountCodeStatus = 'failed';
        }
      }
      setState(() {});
      CustomAlerts().showLoadingAlert(context, 'Applying Code...');
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop();
    }
  }

  validateAndSubmit() {
    setState(() {
      paymentButtonDisabled = true;
    });
    ShowAlertDialogService().showLoadingDialog(context);
    ticketPaymentFormKey.currentState.save();
    cardNumber = cardNumber.replaceAll(" ", "");
    if (firstName == null || firstName.isEmpty) {
      setState(() {
        paymentButtonDisabled = false;
      });
      Navigator.of(context).pop();
      showFormAlert("First Name Cannot be Empty");
    } else if (lastName == null || lastName.isEmpty) {
      setState(() {
        paymentButtonDisabled = false;
      });
      Navigator.of(context).pop();
      showFormAlert("Last Name Cannot be Empty");
    } else if (emailAddress == null || emailAddress.isEmpty) {
      setState(() {
        paymentButtonDisabled = false;
      });
      Navigator.of(context).pop();
      showFormAlert("Email Address Cannot be Empty");
    } else if (!Strings().isEmailValid(emailAddress)) {
      setState(() {
        paymentButtonDisabled = false;
      });
      Navigator.of(context).pop();
      showFormAlert("Please Provide a Valid Email Address");
    } else if (cardNumber == null || cardNumber.length != 16) {
      setState(() {
        paymentButtonDisabled = false;
      });
      Navigator.of(context).pop();
      showFormAlert("Invalid Card Number");
    } else if (expMonth < 1 || expMonth > 12) {
      setState(() {
        paymentButtonDisabled = false;
      });
      Navigator.of(context).pop();
      showFormAlert("Invalid Expiry Month");
    } else if (expYear < DateTime.now().year) {
      setState(() {
        paymentButtonDisabled = false;
      });
      Navigator.of(context).pop();
      showFormAlert("Invalid Expiry Year");
    } else if (cardHolderName == null || cardHolderName.isEmpty) {
      setState(() {
        paymentButtonDisabled = false;
      });
      Navigator.of(context).pop();
      showFormAlert("Name Cannot Be Empty");
    } else if (cvcNumber == null || cvcNumber.length != 3) {
      setState(() {
        paymentButtonDisabled = false;
      });
      Navigator.of(context).pop();
      showFormAlert("Invalid CVC Code");
    } else {
      submitPayment();
    }
  }

  validateFormWithoutPayment() async {
    paymentFormError = null;
    setState(() {
      paymentButtonDisabled = true;
    });
    ShowAlertDialogService().showLoadingDialog(context);
    completePurchase();
    //submitWithoutPayment();
  }

  submitPayment() async {
    StripePaymentService()
        .purchaseTickets(widget.event.title, widget.currentUser.uid, widget.event.authorID, "username", chargeAmount, ticketCharge, numOfTicketsToPurchase,
            cardNumber, expMonth, expYear, cvcNumber, cardHolderName, emailAddress)
        .then((res) {
      if (res == 'passed') {
        print('payment success...');
        StripePaymentService().sendEmailConfirmation(emailAddress, widget.event.title, numOfTicketsToPurchase.toString());
        Navigator.of(context).pop();
        completePurchase();
      } else if (res == "Payment Method Error") {
        setState(() {
          paymentButtonDisabled = false;
        });
        Navigator.of(context).pop();
        CustomAlerts().showErrorAlert(context, "Payment Method Error", "There was an issue with the details of your payment method.");
      } else if (res == "Transaction Error") {
        setState(() {
          paymentButtonDisabled = false;
        });
        Navigator.of(context).pop();
        CustomAlerts().showErrorAlert(context, "Payment Error", "There was an issue charging your card. Please try a different one.");
      } else {
        setState(() {
          paymentButtonDisabled = false;
        });
        Navigator.of(context).pop();
        CustomAlerts().showErrorAlert(context, "Unknown Error", "Please Contact Us via Email: team@webblen.com");
      }
    });
  }

  void completePurchase() {
    StripePaymentService().completeTicketPurchase(widget.currentUser.uid, widget.ticketsToPurchase, widget.event).then((res) {
      if (appliedDiscountCodes.isNotEmpty) {
        TicketDataService().updateUsedDiscountCodes(ticketDistro, widget.event.id);
      }
      ShowAlertDialogService()
          .showActionSuccessDialog(context, "Purchase Successful!", "Your Tickets are in Your Wallet. \n A Receipt Has Been Emailed to You.", () {
        Navigator.of(context).pop();
        PageTransitionService(context: context).returnToRootPage();
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    StripeApi.init("pk_test_gYHQOvqAIkPEMVGQRehk3nj4009Kfodta1");
    TicketDataService().getEventTicketDistro(widget.event.id).then((res) {
      ticketDistro = res;
      PlatformDataService().getEventTicketFee().then((res) {
        ticketRate = res;
        PlatformDataService().getTaxRate().then((res) {
          taxRate = res;
          calculateChargeTotals();
          isLoading = false;
          setState(() {});
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          CustomText(
                            context: context,
                            text: "${widget.event.startDate} | ${widget.event.startTime} ${widget.event.timezone}",
                            textColor: Colors.black45,
                            textAlign: TextAlign.left,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          ticketChargeList(),
                          //widget.eventFees != null && widget.eventFees.isNotEmpty ? eventFeeBuilder() : Container(),
                          additionalFeesAndSalesTax(),
                          discountsInfo(),
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
                          formSectionHeader("Discount Code"),
                          discountCodeAlert(),
                          SizedBox(height: 8.0),
                          discountCodeRow(),
                          SizedBox(height: 32.0),
                          chargeAmount == 0 ? Container() : formSectionHeader("Payment Information"),
                          chargeAmount == 0
                              ? Container()
                              : Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      formFieldHeader("First Name"),
                                      stringFormFieldFor("firstName"),
                                      formFieldHeader("Last Name"),
                                      stringFormFieldFor("lastName"),
                                      formFieldHeader("Email Address"),
                                      stringFormFieldFor("email"),
                                      formSectionHeader("Card Information"),
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
                                      formFieldHeader("Card Holder Name"),
                                      cardHolderNameField(),
                                      formFieldHeader("Card Number"),
                                      cardNumberField(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              formFieldHeader("Expiry Month"),
                                              expiryMonthField(),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              formFieldHeader("Expiry Year"),
                                              expiryYearField(),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              formFieldHeader("CVC"),
                                              cvcField(),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16.0),
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: 16.0,
                                          left: 32.0,
                                          right: 32.0,
                                          bottom: 4.0,
                                        ),
                                        child: Fonts().textW400(
                                          "All data is sent via 256-bit encrypted connection to keep your information secure.",
                                          14.0,
                                          Colors.black,
                                          TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                textColor: Colors.white,
                backgroundColor: FlatColors.darkMountainGreen,
                height: 40.0,
                width: MediaQuery.of(context).size.width * 0.9,
                onPressed: paymentButtonDisabled
                    ? null
                    : chargeAmount == 0
                        ? () => validateFormWithoutPayment()
                        : () => validateAndSubmit(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

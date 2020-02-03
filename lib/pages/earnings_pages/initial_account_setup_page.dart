import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:intl/intl.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services_general/services_show_alert.dart';
import 'package:webblen/styles/flat_colors.dart';
import 'package:webblen/styles/fonts.dart';
import 'package:webblen/utils/open_url.dart';
import 'package:webblen/utils/strings.dart';
import 'package:webblen/widgets/widgets_common/common_appbar.dart';
import 'package:webblen/widgets/widgets_common/common_button.dart';

class InitialAccountSetupPage extends StatefulWidget {
  final WebblenUser currentUser;

  InitialAccountSetupPage({
    this.currentUser,
  });

  @override
  _InitialAccountSetupPageState createState() => _InitialAccountSetupPageState();
}

class _InitialAccountSetupPageState extends State<InitialAccountSetupPage> {
  WebblenUser currentUser;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final individualFormKey = GlobalKey<FormState>();
  final companyFormKey = GlobalKey<FormState>();
  MaskedTextController phoneMaskedTextController = MaskedTextController(mask: '000-000-0000');
  MaskedTextController einMaskedTextController = MaskedTextController(mask: '00-0000000');
  List<String> accountHolderTypes = ['individual', 'company'];
  String accountHolderType = 'individual';

  //INDIVIDUAL INFO
  String firstName;
  String lastName;
  DateTime birthDate;
  int dobMonth;
  int dobDay;
  int dobYear;
  String last4SSN;

  //COMPANY INFO
  String companyName;
  String companyURL;
  String companyEIN;

  //SHARED INFO
  String streetAddress;
  String cityOrProvinceID = "AL";
  String zipCode;
  String phoneNumber;
  String emailAddress;

  //BANKING INFO
  String routingNumber;
  String accountNumber;

  Widget formFieldHeader(String val) {
    return Container(
      margin: EdgeInsets.only(
        top: 8.0,
        left: 16.0,
        right: 16.0,
        bottom: 4.0,
      ),
      child: Fonts().textW700(
        val,
        16.0,
        Colors.black,
        TextAlign.left,
      ),
    );
  }

  Widget stringFormFieldFor(String val) {
    return Container(
      margin: EdgeInsets.only(
        top: 4.0,
        left: 16.0,
        right: 16.0,
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
          contentPadding: EdgeInsets.all(8.0),
          border: InputBorder.none,
        ),
        onSaved: (input) {
          if (val == 'firstName') {
            firstName = input;
          } else if (val == 'lastName') {
            lastName = input;
          } else if (val == 'companyName') {
            companyName = input;
          } else if (val == 'companyURL') {
            companyURL = input;
          } else if (val == 'email') {
            emailAddress = input;
          }
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

  Widget numberFormFieldFor(String val) {
    return Container(
      //height: 45.0,
      margin: EdgeInsets.only(
        top: 4.0,
        left: 16.0,
        right: 8.0,
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
        controller: val == "phoneNumber" ? phoneMaskedTextController : val == "ein" ? einMaskedTextController : null,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(4.0),
          border: InputBorder.none,
        ),
        //maxLength: val == 'zipcode' ? 5 : val == "routingNumber" || val == "ein" ? 9 : val == "last4SSN" ? 4 : null,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
          val == 'zipcode'
              ? LengthLimitingTextInputFormatter(5)
              : val == "routingNumber" || val == "ein"
                  ? LengthLimitingTextInputFormatter(9)
                  : val == "last4SSN" ? LengthLimitingTextInputFormatter(4) : LengthLimitingTextInputFormatter(20),
        ],
        onSaved: (input) {
          if (val == 'zipcode') {
            zipCode = input;
          } else if (val == 'routingNumber') {
            routingNumber = input;
          } else if (val == 'accountNumber') {
            accountNumber = input;
          } else if (val == 'last4SSN') {
            last4SSN = input;
          } else if (val == 'ein') {
            companyEIN = input;
          }
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

  showPickerDateTime(BuildContext context) {
    Picker(
      adapter: DateTimePickerAdapter(
        customColumnType: [
          1,
          2,
          0,
        ],
        isNumberMonth: false,
        //yearBegin: DateTime.now().year,
        yearEnd: DateTime.now().year,
      ),
      onConfirm: (
        Picker picker,
        List value,
      ) {
        DateTime selectedDate = (picker.adapter as DateTimePickerAdapter).value;
        birthDate = selectedDate;
        setState(() {});
      },
    ).show(scaffoldKey.currentState);
  }

  Widget stateSelectField() {
    return Container(
      margin: EdgeInsets.only(
        top: 4.0,
        right: 16.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: FlatColors.iosOffWhite,
        border: Border.all(width: 1.0, color: Colors.black12),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          underline: Container(),
          isDense: true,
          isExpanded: true,
          value: cityOrProvinceID,
          items: Strings.statesList.map((val) {
            return DropdownMenuItem(
              child: Fonts().textW500(val, 18.0, Colors.black, TextAlign.left),
              value: val,
            );
          }).toList(),
          onChanged: (selectedValue) {
            setState(() {
              cityOrProvinceID = selectedValue;
            });
          },
        ),
      ),
    );
  }

  Widget bankingDetails() {
    return Column(
      children: <Widget>[
        SizedBox(height: 32.0),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          child: Fonts().textW700(
            "Add your bank details to receive your earnings directly into your bank account.",
            16.0,
            Colors.black,
            TextAlign.left,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 16.0,
          ),
          child: Fonts().textW400(
            "To keep your earnings secure, payments from Webblen will be placed on hold for 24 hours. Once your bank account has been verified, any earnings from Webblen during this time will be paid out to your account on the following Monday. This is to ensure your earnings go to your bank account.",
            16.0,
            Colors.black,
            TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget bankingInfoQuickGuide() {
    return GestureDetector(
      onTap: () => ShowAlertDialogService().showCheckExampleDialog(context),
      child: Fonts().textW500(
        "Where Do I Find These Numbers?",
        14.0,
        Colors.black54,
        TextAlign.center,
      ),
    );
  }

  void validateAndSubmitForm() {
    individualFormKey.currentState.save();
    ScaffoldState scaffoldState = scaffoldKey.currentState;
//    if (accountHolderName == null || accountHolderName.isEmpty) {
//      scaffoldState.showSnackBar(
//        SnackBar(
//          content: Text("Please Enter a Name for the Account"),
//          backgroundColor: Colors.red,
//          duration: Duration(seconds: 2),
//        ),
//      );
//    } else if (routingNumber == null || routingNumber.length != 9) {
//      scaffoldState.showSnackBar(
//        SnackBar(
//          content: Text("Please Enter a Valid Routing Number"),
//          backgroundColor: Colors.red,
//          duration: Duration(seconds: 2),
//        ),
//      );
//    } else if (accountNumber == null || accountNumber.isEmpty) {
//      scaffoldState.showSnackBar(
//        SnackBar(
//          content: Text("Please Enter a Valid Account Number"),
//          backgroundColor: Colors.red,
//          duration: Duration(seconds: 2),
//        ),
//      );
//    } else {
//      StripeDataService()
//          .submitBankingInfoToStripe(currentUser.uid, stripeUID, accountHolderName, accountHolderType, routingNumber, accountNumber)
//          .then((status) {
//        Navigator.of(context).pop();
//      });
//    }
  }

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
//    StripeDataService().getStripeUID(currentUser.uid).then((val) {
//      if (val != null) {
//        stripeUID = val;
//      }
//      setState(() {});
//    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat("MMM dd, yyyy");

    final accountHolderTypeField = Container(
      margin: EdgeInsets.only(
        top: 4.0,
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),
      decoration: BoxDecoration(
        color: FlatColors.iosOffWhite,
        border: Border.all(width: 1.0, color: Colors.black12),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: DropdownButton<String>(
          underline: Container(),
          isDense: true,
          isExpanded: true,
          value: accountHolderType,
          items: accountHolderTypes.map((val) {
            return DropdownMenuItem(
              child: Fonts().textW500(val, 16.0, Colors.black, TextAlign.left),
              value: val,
            );
          }).toList(),
          onChanged: (selectedValue) {
            setState(() {
              accountHolderType = selectedValue;
            });
          },
        ),
      ),
    );

    //Individual Form
    Widget individualForm = Form(
      key: individualFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          formFieldHeader("FIRST NAME"),
          stringFormFieldFor("firstName"),
          formFieldHeader("LAST NAME"),
          stringFormFieldFor("lastName"),
          formFieldHeader("DATE OF BIRTH"),
          Padding(
            padding: EdgeInsets.only(
              top: 4.0,
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: GestureDetector(
              onTap: () => showPickerDateTime(context),
              child: Fonts().textW400(birthDate == null ? "Select Birthday" : formatter.format(birthDate), 18.0, Colors.blueAccent, TextAlign.left),
            ),
          ),
          formFieldHeader("LAST 4 OF SSN"),
          numberFormFieldFor("last4SSN"),
          formFieldHeader("STREET ADDRESS"),
          stringFormFieldFor("streetAddress"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    formFieldHeader("ZIPCODE"),
                    numberFormFieldFor("zipcode"),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    formFieldHeader("STATE"),
                    stateSelectField(),
                  ],
                ),
              ),
            ],
          ),
          formFieldHeader("EMAIL ADDRESS"),
          stringFormFieldFor("email"),
          formFieldHeader("PHONE NUMBER"),
          numberFormFieldFor("phoneNumber"),
          bankingDetails(),
          formFieldHeader("BANK ROUTING NUMBER"),
          numberFormFieldFor("routingNumber"),
          formFieldHeader("BANK ACCOUNT NUMBER"),
          numberFormFieldFor("acountNumber"),
          bankingInfoQuickGuide()
        ],
      ),
    );

    //Company Form
    Widget companyForm = Form(
      key: companyFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          formFieldHeader("COMPANY NAME"),
          stringFormFieldFor("companyName"),
          formFieldHeader("COMPANY URL"),
          stringFormFieldFor("companyURL"),
          formFieldHeader("COMPANY EIN"),
          numberFormFieldFor("companyEIN"),
          formFieldHeader("BUSINESS ADDRESS"),
          stringFormFieldFor("streetAddress"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    formFieldHeader("ZIPCODE"),
                    numberFormFieldFor("zipcode"),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    formFieldHeader("STATE"),
                    stateSelectField(),
                  ],
                ),
              ),
            ],
          ),
          formFieldHeader("EMAIL ADDRESS"),
          stringFormFieldFor("email"),
          formFieldHeader("PHONE NUMBER"),
          numberFormFieldFor("phoneNumber"),
          bankingDetails(),
          formFieldHeader("BANK ROUTING NUMBER"),
          numberFormFieldFor("routingNumber"),
          formFieldHeader("BANK ACCOUNT NUMBER"),
          numberFormFieldFor("acountNumber"),
          bankingInfoQuickGuide()
        ],
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: WebblenAppBar().basicAppBar("Set Up Earnings Account", context),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            SizedBox(height: 32.0),
            formFieldHeader('ACCOUNT TYPE'),
            accountHolderTypeField,
            accountHolderType == 'individual' ? individualForm : companyForm,
            Container(
              margin: EdgeInsets.only(
                top: 64.0,
                left: 32.0,
                right: 32.0,
                bottom: 4.0,
              ),
              child: Fonts().textW400(
                "Please confirm your bank details before sumbission. \n Incorrect details may lead to delayed payments.",
                12.0,
                Colors.black,
                TextAlign.center,
              ),
            ),
            CustomColorButton(
              text: "Register Account",
              textColor: Colors.white,
              backgroundColor: FlatColors.webblenRed,
              height: 45.0,
              width: MediaQuery.of(context).size.width * 0.6,
              onPressed: () => validateAndSubmitForm(),
            ),
            Container(
              margin: EdgeInsets.only(
                top: 16.0,
                left: 32.0,
                right: 32.0,
                bottom: 4.0,
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'By registering your account, you agree to our ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.0,
                        fontFamily: "Helvetica Neue",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                        text: 'Terms of Services ',
                        style: TextStyle(
                          color: FlatColors.webblenRed,
                          fontSize: 12.0,
                          fontFamily: "Helvetica Neue",
                          fontWeight: FontWeight.w400,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            OpenUrl().launchInWebViewOrVC(context, 'https://www.webblen.io/privacy');
                          }),
                    TextSpan(
                      text: 'and the ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.0,
                        fontFamily: "Helvetica Neue",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                        text: 'Stripe Connected Account Agreement.',
                        style: TextStyle(
                          color: FlatColors.webblenRed,
                          fontSize: 12.0,
                          fontFamily: "Helvetica Neue",
                          fontWeight: FontWeight.w400,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            OpenUrl().launchInWebViewOrVC(context, 'https://stripe.com/connect-account/legal');
                          }),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: 32.0,
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
    );
  }
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:webblen/app/app.locator.dart';
import 'package:webblen/models/webblen_event.dart';
import 'package:webblen/models/webblen_notification.dart';
import 'package:webblen/models/webblen_ticket_distro.dart';
import 'package:webblen/models/webblen_user.dart';
import 'package:webblen/services/bottom_sheets/custom_bottom_sheets_service.dart';
import 'package:webblen/services/dialogs/custom_dialog_service.dart';
import 'package:webblen/services/email/email_service.dart';
import 'package:webblen/services/firestore/data/event_data_service.dart';
import 'package:webblen/services/firestore/data/notification_data_service.dart';
import 'package:webblen/services/firestore/data/platform_data_service.dart';
import 'package:webblen/services/firestore/data/ticket_distro_data_service.dart';
import 'package:webblen/services/firestore/data/user_data_service.dart';
import 'package:webblen/services/navigation/custom_navigation_service.dart';
import 'package:webblen/services/reactive/user/reactive_user_service.dart';
import 'package:webblen/services/stripe/stripe_payment_service.dart';
import 'package:webblen/utils/custom_string_methods.dart';

class TicketPurchaseViewModel extends ReactiveViewModel {
  NotificationDataService _notificationDataService = locator<NotificationDataService>();
  EmailService _emailService = locator<EmailService>();
  CustomNavigationService _customNavigationService = locator<CustomNavigationService>();
  UserDataService _userDataService = locator<UserDataService>();
  EventDataService _eventDataService = locator<EventDataService>();
  TicketDistroDataService _ticketDistroDataService = locator<TicketDistroDataService>();
  CustomDialogService customDialogService = locator<CustomDialogService>();
  CustomBottomSheetService customBottomSheetService = locator<CustomBottomSheetService>();
  ReactiveUserService _reactiveUserService = locator<ReactiveUserService>();
  PlatformDataService _platformDataService = locator<PlatformDataService>();
  StripePaymentService _stripePaymentService = locator<StripePaymentService>();

  ///AUTH HELPERS
  final phoneMaskController = MaskedTextController(mask: '000-000-0000');
  final smsController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool signInViaPhone = true;
  String? phoneNo;
  late String phoneVerificationID;

  ///USER DATA
  WebblenUser get user => _reactiveUserService.user;

  ///HOST
  WebblenUser? host;

  ///NOTIFS
  WebblenNotification purchaseNotif = WebblenNotification();
  WebblenNotification soldNotif = WebblenNotification();

  ///TICKET DATA
  WebblenEvent? event;
  DateFormat formatter = DateFormat('MMM dd, yyyy h:mm a');
  WebblenTicketDistro? ticketDistro;

  //payments
  List ticketsToPurchase = [];

  bool isLoading = true;
  bool hasAccount = false;
  bool acceptedTermsAndConditions = true;
  GlobalKey authFormKey = GlobalKey<FormState>();
  GlobalKey ticketPaymentFormKey = GlobalKey<FormState>();
  GlobalKey discountCodeFormKey = GlobalKey<FormState>();

  //payments
  int numOfTicketsToPurchase = 0;
  double? ticketRate;
  double? taxRate;
  double ticketCharge = 0.00;
  double ticketFeeCharge = 0.00;
  double customFeeCharge = 0.00;
  double taxCharge = 0.00;
  double chargeAmount = 0.0;
  double discountAmount = 0.0;
  String? discountCodeDescription;
  List<String> appliedDiscountCodes = [];
  String? discountCodeStatus;
  String? discountCode;
  bool applyingDiscountCode = false;
  bool processingPayment = false;
  List<String> ticketEmails = [];

  //Customer Info
  String? firstName;
  String? lastName;
  String? emailAddress;
  String? areaCode;

  ///CARD DATA
  bool cvcFocused = false;
  String cardNumber = "";
  String expiryDate = "MM/YY";
  int? expMonth;
  int? expYear;
  String cardHolderName = "";
  String cvcNumber = "";

  String? paymentFormError;
  var cardNumberMask = MaskedTextController(mask: '0000 0000 0000 0000');
  var expiryDateMask = MaskedTextController(mask: 'XX/XX');
  String? stripeUID;

  //Auth Info
  String? authEmail;
  String? authPass;
  String? authConfirmPass;
  String? authUsername;
  String? authFormError;

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_reactiveUserService];

  ///INITIALIZE
  initialize({required String eventID, required String selectedTickets}) async {
    setBusy(true);

    // .value will return the raw string value
    String id = eventID;

    //get event data
    var res = await _eventDataService.getEventByID(id);
    if (!res.isValid()) {
      _customNavigationService.navigateBack();
      return;
    } else {
      event = res;
    }

    //get author info
    host = await _userDataService.getWebblenUserByID(event!.authorID);

    //get ticket distro
    ticketDistro = await _ticketDistroDataService.getTicketDistroByID(event!.id);

    //get ticket data
    ticketsToPurchase = json.decode(Uri.decodeComponent(selectedTickets));

    //get fee & tax data
    ticketRate = await _platformDataService.getEventTicketFee();
    taxRate = await _platformDataService.getTaxRate();
    //calculate totals
    calculateChargeTotals();

    //pre-generate notifications to send
    purchaseNotif = WebblenNotification().generateTicketsPurchasedNotification(
      eventID: event!.id!,
      eventTitle: event!.title!,
      uid: user.id!,
      numberOfTickets: numOfTicketsToPurchase,
    );
    soldNotif = WebblenNotification().generateTicketsSoldNotification(
      receiverUID: event!.authorID!,
      senderUID: user.id!,
      eventTitle: event!.title!,
      numberOfTickets: numOfTicketsToPurchase,
    );

    notifyListeners();
    setBusy(false);
  }

  calculateChargeTotals() {
    ticketsToPurchase.forEach((ticket) {
      int purchaseQty = ticket['purchaseQty'];
      double ticketPrice = double.parse(ticket['ticketPrice'].toString().replaceAll("\$", ""));
      double charge = ticketPrice * purchaseQty;
      numOfTicketsToPurchase = numOfTicketsToPurchase + purchaseQty;
      ticketCharge = ticketCharge + charge;
    });
    ticketFeeCharge = numOfTicketsToPurchase * ticketRate!;
    taxCharge = (ticketCharge + ticketFeeCharge) * taxRate!;
    chargeAmount = ticketCharge + ticketFeeCharge + taxCharge;
    notifyListeners();
  }

  applyDiscountCode() async {
    applyingDiscountCode = true;
    notifyListeners();

    if (discountCode == null) {
      discountCodeStatus = 'failed';
      applyingDiscountCode = false;
      notifyListeners();
      return;
    } else {
      int discountCodeIndex = ticketDistro!.discountCodes!.indexWhere((code) => code['discountName'] == discountCode);
      if (appliedDiscountCodes.contains(discountCode)) {
        discountCodeStatus = 'duplicate';
      } else if (appliedDiscountCodes.isNotEmpty) {
        discountCodeStatus = 'multiple';
      } else {
        if (discountCodeIndex >= 0) {
          Map<String, dynamic> code = ticketDistro!.discountCodes![discountCodeIndex];
          int discountLimit = int.parse(code['discountLimit']);
          if (discountLimit <= 0) {
            discountCodeStatus = 'failed';
          } else {
            discountAmount = double.parse(code['discountValue'].replaceAll("\$", ""));
            discountCodeDescription = " \$${(discountAmount).toStringAsFixed(2)} off ";
            ticketCharge = ticketCharge - discountAmount;
            if (ticketCharge <= 0) {
              ticketCharge = 0;
              ticketFeeCharge = 0;
              taxCharge = (ticketCharge + ticketFeeCharge) * taxRate!;
              chargeAmount = ticketCharge + ticketFeeCharge + taxCharge;
            } else {
              ticketFeeCharge = numOfTicketsToPurchase * ticketRate!;
              taxCharge = (ticketCharge + ticketFeeCharge) * taxRate!;
              chargeAmount = ticketCharge + ticketFeeCharge + taxCharge;
            }
            appliedDiscountCodes.add(discountCode!);
            discountCodeStatus = 'passed';
          }
        } else {
          discountCodeStatus = 'failed';
        }
      }
    }

    applyingDiscountCode = false;
    notifyListeners();
  }

  ///FORM HANDLERS
  updateDiscountCode(String val) {
    discountCode = val.trim();
    notifyListeners();
  }

  updateEmailAddress(String val) {
    emailAddress = val.trim();
    notifyListeners();
  }

  updateCardHolderName(String val) {
    cvcFocused = false;
    cardHolderName = val.trim();
    notifyListeners();
  }

  updateCardNumber(String val) {
    cvcFocused = false;
    cardNumber = val.replaceAll(" ", "");
    notifyListeners();
  }

  updateExpiryDate(String val) {
    cvcFocused = false;
    expiryDate = val.trim();
    notifyListeners();
  }

  updateExpiryMonth(String val) {
    cvcFocused = false;
    expMonth = int.parse(val);
    notifyListeners();
  }

  updateExpiryYear(String val) {
    cvcFocused = false;
    expYear = int.parse("20$val"); //sets year to 20XX
    notifyListeners();
  }

  updateCVC(String val) {
    cvcFocused = true;
    cvcNumber = val;
    notifyListeners();
  }

  acceptTermsAndConditions(bool val) {
    acceptedTermsAndConditions = val;
    notifyListeners();
  }

  bool formIsValid() {
    bool isValid = true;
    if (emailAddress == null || !isValidEmail(emailAddress!)) {
      customDialogService.showErrorDialog(description: "Please provide a valid email address");
      isValid = false;
    } else if (cardNumber.length != 16) {
      customDialogService.showErrorDialog(description: "Invalid Card Number");
      isValid = false;
    } else if (expMonth == null || expMonth! < 1 || expMonth! > 12) {
      customDialogService.showErrorDialog(description: "Invalid Expiry Month");
      isValid = false;
    } else if (expYear == null || expYear! < DateTime.now().year) {
      customDialogService.showErrorDialog(description: "Invalid Expiry Year");
      isValid = false;
    } else if (DateTime.now().isAtSameMomentAs(DateTime(expYear!, expMonth!)) || DateTime.now().isAfter(DateTime(expYear!, expMonth!))) {
      customDialogService.showErrorDialog(description: "This Card Has Expired");
      isValid = false;
    } else if (cvcNumber.length != 3) {
      customDialogService.showErrorDialog(description: "Invalid CVC Code");
      isValid = false;
    } else if (cardHolderName.isEmpty) {
      customDialogService.showErrorDialog(description: "Name Cannot Be Empty");
      isValid = false;
    }
    return isValid;
  }

  processPurchase() async {
    if (chargeAmount <= 0) {
      processingPayment = true;
      notifyListeners();
      if (emailAddress == null || !isValidEmail(emailAddress!)) {
        customDialogService.showErrorDialog(description: "Please provide a valid email address");
        processingPayment = false;
        notifyListeners();
        return;
      }
      await _notificationDataService.sendNotification(notif: purchaseNotif);
      await _notificationDataService.sendNotification(notif: soldNotif);
      List purchasedTickets = await _ticketDistroDataService.completeTicketPurchase(uid: user.id!, event: event!, ticketsToPurchase: ticketsToPurchase);
      _emailService.sendTicketPurchaseConfirmationEmail(
        emailAddress: emailAddress!,
        eventTitle: event!.title!,
        purchasedTickets: purchasedTickets,
        additionalTaxesAndFees: "\$${(ticketFeeCharge + taxCharge).toStringAsFixed(2)}",
        discountCodeDescription: discountCodeDescription == null ? "" : discountCodeDescription!,
        discountValue: "- \$${discountAmount.toStringAsFixed(2)}",
        totalCharge: "\$${chargeAmount.toStringAsFixed(2)}",
      );
      if (discountCode != null && discountCodeDescription != null) {
        _ticketDistroDataService.updateUsedDiscountCode(eventID: event!.id!, ticketDistro: ticketDistro!, discountCode: discountCode!);
      }
      _customNavigationService.navigateToTicketPurchaseSuccessView(emailAddress!);
    } else if (formIsValid()) {
      processingPayment = true;
      notifyListeners();
      String? status = await _stripePaymentService.processTicketPurchase(
        eventTitle: event!.title!,
        purchaserID: user.id!,
        eventHostID: event!.authorID!,
        eventHostName: host!.username!,
        totalCharge: chargeAmount,
        ticketCharge: ticketCharge,
        numberOfTickets: numOfTicketsToPurchase,
        cardNumber: cardNumber,
        expMonth: expMonth!,
        expYear: expYear!,
        cvcNumber: cvcNumber,
        cardHolderName: cardHolderName,
        email: emailAddress!,
      );
      if (status == "passed") {
        await _notificationDataService.sendNotification(notif: purchaseNotif);
        await _notificationDataService.sendNotification(notif: soldNotif);
        List purchasedTickets = await _ticketDistroDataService.completeTicketPurchase(uid: user.id!, event: event!, ticketsToPurchase: ticketsToPurchase);
        _emailService.sendTicketPurchaseConfirmationEmail(
          emailAddress: emailAddress!,
          eventTitle: event!.title!,
          purchasedTickets: purchasedTickets,
          additionalTaxesAndFees: "\$${(ticketFeeCharge + taxCharge).toStringAsFixed(2)}",
          discountCodeDescription: discountCodeDescription == null ? "" : discountCodeDescription!,
          discountValue: "- \$${discountAmount.toStringAsFixed(2)}",
          totalCharge: "\$${chargeAmount.toStringAsFixed(2)}",
        );
        if (discountCode != null && discountCodeDescription != null) {
          _ticketDistroDataService.updateUsedDiscountCode(eventID: event!.id!, ticketDistro: ticketDistro!, discountCode: discountCode!);
        }
        _customNavigationService.navigateToTicketPurchaseSuccessView(emailAddress!);
      } else {
        customDialogService.showErrorDialog(description: status!);
      }
      processingPayment = false;
      notifyListeners();
    }
  }
}

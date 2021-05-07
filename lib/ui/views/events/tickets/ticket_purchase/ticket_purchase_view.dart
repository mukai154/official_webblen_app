import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_hooks/stacked_hooks.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/events/tickets/ticket_purchase/ticket_purchase_view_model.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_text_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';
import 'package:webblen/ui/widgets/common/text_field/text_field_container.dart';

class TicketPurchaseView extends StatelessWidget {
  final String? id;
  final String? ticketsToPurchase;
  TicketPurchaseView(@PathParam() this.id, @PathParam() this.ticketsToPurchase);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TicketPurchaseViewModel>.reactive(
      onModelReady: (model) => model.initialize(eventID: id!, selectedTickets: ticketsToPurchase!),
      viewModelBuilder: () => TicketPurchaseViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicAppBar(
          title: "Purchase Tickets",
          showBackButton: true,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: screenHeight(context),
            color: appBackgroundColor(),
            child: model.isBusy
                ? Center(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Center(
                          child: CustomCircleProgressIndicator(
                            size: 10,
                            color: appActiveColor(),
                          ),
                        ),
                      ],
                    ),
                  )
                : Align(
                    alignment: Alignment.topCenter,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              SizedBox(height: 32.0),

                              ///TICKET CHARGE DETAILS
                              _TicketPurchaseHead(),
                              _TicketChargeList(),
                              _AdditionalFeesAndSalesTax(),
                              _DiscountInfo(),

                              verticalSpaceSmall,
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: 500,
                                ),
                                child: Divider(
                                  height: 1,
                                  thickness: 3,
                                  color: appDividerColor(),
                                ),
                              ),
                              verticalSpaceSmall,
                              _ChargeTotal(),
                              verticalSpaceMedium,

                              ///DISCOUNT CODE
                              _DiscountCodeField(),
                              verticalSpaceMedium,

                              ///CARD FORM
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                constraints: BoxConstraints(
                                  maxWidth: 500,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    CustomText(
                                      text: "Email Address",
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: appFontColor(),
                                      textAlign: TextAlign.left,
                                    ),
                                    verticalSpaceSmall,
                                    _EmailAddressField(),
                                    verticalSpaceMedium,
                                    CustomText(
                                      text: "Card Number",
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: appFontColor(),
                                      textAlign: TextAlign.left,
                                    ),
                                    verticalSpaceSmall,
                                    _CardNumField(),
                                    verticalSpaceMedium,
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          width: 100,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              CustomText(
                                                text: "Exp Month",
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: appFontColor(),
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(height: 8.0),
                                              _ExpiryMonthField(),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 100,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              CustomText(
                                                text: "Exp Year",
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: appFontColor(),
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(height: 8.0),
                                              _ExpiryYearField(),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 100,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              CustomText(
                                                text: "CVC",
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: appFontColor(),
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(height: 8.0),
                                              _CVCField(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 16.0),
                                    CustomText(
                                      text: "Card Holder Name",
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: appFontColor(),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(height: 8.0),
                                    _CardHolderNameField(),
                                  ],
                                ),
                              ),
                              SizedBox(height: 32.0),
                              _PurchaseTicketsButton(),
                              SizedBox(height: 32.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _TicketPurchaseHead extends HookViewModelWidget<TicketPurchaseViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, TicketPurchaseViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints(
        maxWidth: 500,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 16.0,
          ),
          CustomText(
            text: model.event!.title,
            textAlign: TextAlign.center,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: appFontColor(),
          ),
          SizedBox(
            height: 4.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CustomText(
                text: "hosted by ",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: appFontColor(),
              ),
              CustomTextButton(
                onTap: () {},
                text: "@${model.host!.username}",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: appActiveColor(),
              ),
            ],
          ),
          SizedBox(
            height: 4.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                FontAwesomeIcons.mapMarkerAlt,
                size: 14.0,
                color: Colors.black38,
              ),
              SizedBox(width: 4.0),
              CustomText(
                text: "${model.event!.city}, ${model.event!.province}",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.left,
                color: appFontColorAlt(),
              ),
            ],
          ),
          SizedBox(
            height: 4.0,
          ),
          CustomText(
            text: "${model.event!.startDate} | ${model.event!.startTime}",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
            color: appFontColorAlt(),
          ),
          SizedBox(
            height: 16.0,
          ),
        ],
      ),
    );
  }
}

class _TicketChargeList extends HookViewModelWidget<TicketPurchaseViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, TicketPurchaseViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints(
        maxWidth: 500,
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          verticalSpaceMedium,
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: model.ticketsToPurchase.length,
            itemBuilder: (BuildContext context, int index) {
              double ticketPrice = double.parse(model.ticketsToPurchase[index]['ticketPrice'].toString().substring(1));
              double ticketCharge = ticketPrice * model.ticketsToPurchase[index]['purchaseQty'];
              return model.ticketsToPurchase[index]['purchaseQty'] > 0
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
                              text: "${model.ticketsToPurchase[index]["ticketName"]} (${model.ticketsToPurchase[index]["purchaseQty"]})",
                              color: appFontColor(),
                              textAlign: TextAlign.left,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            //width: 95,
                            child: CustomText(
                              text: "+ \$${ticketCharge.toStringAsFixed(2)}",
                              color: appFontColor(),
                              textAlign: TextAlign.right,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container();
            },
          ),
        ],
      ),
    );
  }
}

class _AdditionalFeesAndSalesTax extends HookViewModelWidget<TicketPurchaseViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, TicketPurchaseViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints(
        maxWidth: 500,
      ),
      height: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: CustomText(
              text: 'Additional Fees & Sales Tax',
              textAlign: TextAlign.left,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: appFontColor(),
            ),
          ),
          Container(
            child: CustomText(
              text: "+ \$${(model.ticketFeeCharge + model.taxCharge).toStringAsFixed(2)}",
              textAlign: TextAlign.left,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: appFontColor(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscountInfo extends HookViewModelWidget<TicketPurchaseViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, TicketPurchaseViewModel model) {
    return model.discountAmount == 0.0
        ? Container()
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            constraints: BoxConstraints(
              maxWidth: 500,
            ),
            height: 40.0,
            //width: MediaQuery.of(context).size.width * 0.60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  //width: MediaQuery.of(context).size.width * 0.60,
                  child: CustomText(
                    text: "Discount (${model.discountCodeDescription})",
                    textAlign: TextAlign.left,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: appFontColor(),
                  ),
                ),
                Container(
                  //width: 95,
                  child: CustomText(
                    text: "- \$${model.discountAmount.toStringAsFixed(2)}",
                    textAlign: TextAlign.left,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: appDestructiveColor(),
                  ),
                ),
              ],
            ),
          );
  }
}

class _ChargeTotal extends HookViewModelWidget<TicketPurchaseViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, TicketPurchaseViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints(
        maxWidth: 500,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          CustomText(
            text: "Total: ",
            textAlign: TextAlign.left,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: appFontColor(),
          ),
          CustomText(
            text: "\$${model.chargeAmount.toStringAsFixed(2)}",
            textAlign: TextAlign.left,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: appFontColor(),
          ),
        ],
      ),
    );
  }
}

class _DiscountCodeStatus extends HookViewModelWidget<TicketPurchaseViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, TicketPurchaseViewModel model) {
    return model.discountCodeStatus == null
        ? Container()
        : model.discountCodeStatus == 'duplicate'
            ? Container(
                constraints: BoxConstraints(
                  maxWidth: 500,
                ),
                child: CustomText(
                  text: "This Code Has Already Been Used",
                  textAlign: TextAlign.left,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: appDestructiveColor(),
                ),
              )
            : model.discountCodeStatus == 'passed'
                ? Container(
                    constraints: BoxConstraints(
                      maxWidth: 500,
                    ),
                    child: CustomText(
                      text: "Discount Applied Successfully",
                      textAlign: TextAlign.left,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  )
                : model.discountCodeStatus == 'multiple'
                    ? Container(
                        constraints: BoxConstraints(
                          maxWidth: 500,
                        ),
                        child: CustomText(
                          text: "Only One Code Can Be Used at a Time",
                          textAlign: TextAlign.left,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: appDestructiveColor(),
                        ),
                      )
                    : Container(
                        constraints: BoxConstraints(
                          maxWidth: 500,
                        ),
                        child: CustomText(
                          text: "Invalid Code",
                          textAlign: TextAlign.left,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: appDestructiveColor(),
                        ),
                      );
  }
}

class _DiscountCodeField extends HookViewModelWidget<TicketPurchaseViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, TicketPurchaseViewModel model) {
    final discountCode = useTextEditingController();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints(
        maxWidth: 500,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            text: "Discount Code:",
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: appFontColor(),
            textAlign: TextAlign.left,
          ),
          verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TextFieldContainer(
                width: 200.0,
                child: TextFormField(
                  controller: discountCode,
                  cursorColor: appFontColor(),
                  onChanged: (val) {
                    discountCode.selection = TextSelection.fromPosition(TextPosition(offset: discountCode.text.length));
                    model.updateDiscountCode(val);
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Discount Code",
                    border: InputBorder.none,
                  ),
                ),
              ),
              CustomButton(
                text: "Apply",
                textSize: 14,
                height: 35,
                width: 100,
                onPressed: () => model.applyDiscountCode(),
                backgroundColor: appTextFieldContainerColor(),
                textColor: appFontColor(),
                elevation: 1.0,
                isBusy: model.applyingDiscountCode,
              ),
            ],
          ),
          verticalSpaceSmall,
          _DiscountCodeStatus(),
        ],
      ),
    );
  }
}

class _EmailAddressField extends HookViewModelWidget<TicketPurchaseViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, TicketPurchaseViewModel model) {
    var emailAddress = useTextEditingController();
    return TextFieldContainer(
      child: TextFormField(
        controller: emailAddress,
        decoration: InputDecoration(
          hintText: "Email Address",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: model.updateEmailAddress,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );
  }
}

class _CardNumField extends HookViewModelWidget<TicketPurchaseViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, TicketPurchaseViewModel model) {
    var cardNumField = useTextEditingController();
    var maskFormatter = MaskTextInputFormatter(mask: '#### #### #### ####', filter: {"#": RegExp(r'[0-9]')});

    return TextFieldContainer(
      child: TextFormField(
        controller: cardNumField,
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
          String maskedText = maskFormatter.maskText(val);
          cardNumField.text = maskedText;
          cardNumField.selection = TextSelection.fromPosition(TextPosition(offset: cardNumField.text.length));
          model.updateCardNumber(maskedText);
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          LengthLimitingTextInputFormatter(19),
        ],
        keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
        autocorrect: false,
      ),
    );
  }
}

class _ExpiryMonthField extends HookViewModelWidget<TicketPurchaseViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, TicketPurchaseViewModel model) {
    var expiryMonth = useTextEditingController();
    var maskFormatter = MaskTextInputFormatter(mask: '##', filter: {"#": RegExp(r'[0-9]')});
    return TextFieldContainer(
      width: 100,
      child: TextFormField(
        controller: expiryMonth,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "XX",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          String maskedText = maskFormatter.maskText(val);
          expiryMonth.text = maskedText;
          expiryMonth.selection = TextSelection.fromPosition(TextPosition(offset: expiryMonth.text.length));
          model.updateExpiryMonth(maskedText);
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );
  }
}

class _ExpiryYearField extends HookViewModelWidget<TicketPurchaseViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, TicketPurchaseViewModel model) {
    var expiryYear = useTextEditingController();
    var maskFormatter = MaskTextInputFormatter(mask: '##', filter: {"#": RegExp(r'[0-9]')});
    return TextFieldContainer(
      width: 100,
      child: TextFormField(
        controller: expiryYear,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "XX",
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          String maskedText = maskFormatter.maskText(val);
          expiryYear.text = maskedText;
          expiryYear.selection = TextSelection.fromPosition(TextPosition(offset: expiryYear.text.length));
          model.updateExpiryYear(maskedText);
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );
  }
}

class _CVCField extends HookViewModelWidget<TicketPurchaseViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, TicketPurchaseViewModel model) {
    var cvc = useTextEditingController();
    var maskFormatter = MaskTextInputFormatter(mask: '###', filter: {"#": RegExp(r'[0-9]')});
    return TextFieldContainer(
      width: 100,
      child: TextFormField(
        controller: cvc,
        keyboardType: TextInputType.number,
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
          String maskedText = maskFormatter.maskText(val);
          cvc.text = maskedText;
          cvc.selection = TextSelection.fromPosition(TextPosition(offset: cvc.text.length));
          model.updateCVC(maskedText);
        },
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(9),
        ],
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );
  }
}

class _CardHolderNameField extends HookViewModelWidget<TicketPurchaseViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, TicketPurchaseViewModel model) {
    var cardHolderName = useTextEditingController();
    return TextFieldContainer(
      child: TextFormField(
        controller: cardHolderName,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          border: InputBorder.none,
        ),
        onChanged: model.updateCardHolderName,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 1,
        textInputAction: TextInputAction.done,
        autocorrect: false,
      ),
    );
  }
}

class _PurchaseTicketsButton extends HookViewModelWidget<TicketPurchaseViewModel> {
  @override
  Widget buildViewModelWidget(BuildContext context, TicketPurchaseViewModel model) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints(
        maxWidth: 500,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            text: "Please confirm your card details before submission.",
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: appFontColor(),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.0),
          CustomButton(
            text: "Purchase Tickets",
            textSize: 16,
            textColor: Colors.white,
            backgroundColor: CustomColors.darkMountainGreen,
            height: 45.0,
            width: screenWidth(context),
            onPressed: () => model.processPurchase(),
            elevation: 1,
            isBusy: model.processingPayment,
          ),
          SizedBox(height: 16.0),
          CustomText(
            text: "All data is sent via 256-bit encrypted connection to keep your information secure.",
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: appFontColor(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

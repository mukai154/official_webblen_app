import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/text_field/money_text_field.dart';
import 'package:webblen/ui/widgets/common/text_field/number_text_field.dart';
import 'package:webblen/ui/widgets/common/text_field/single_line_text_field.dart';

class TicketingForm extends StatelessWidget {
  final bool editingTicket;
  final TextEditingController ticketNameTextController;
  final TextEditingController ticketQuantityTextController;
  final MoneyMaskedTextController ticketPriceTextController;
  final VoidCallback validateAndSubmitTicket;
  final VoidCallback deleteTicket;
  TicketingForm(
      {required this.editingTicket,
      required this.ticketNameTextController,
      required this.ticketQuantityTextController,
      required this.ticketPriceTextController,
      required this.validateAndSubmitTicket,
      required this.deleteTicket});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth(context),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: (MediaQuery.of(context).size.width - 16) * 0.40,
                  child: CustomText(
                    text: 'Ticket Name',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: appFontColor(),
                  ),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width - 16) * 0.20,
                  child: CustomText(
                    text: 'Qty',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: appFontColor(),
                  ),
                ),
                Container(
                  width: (MediaQuery.of(context).size.width - 16) * 0.20,
                  child: CustomText(
                    text: 'Price',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: appFontColor(),
                  ),
                ),
              ],
            ),
          ),
          verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: (MediaQuery.of(context).size.width - 16) * 0.40,
                child: SingleLineTextField(
                  controller: ticketNameTextController,
                  hintText: "General Admission",
                  textLimit: 50,
                  isPassword: false,
                ),
              ),
              Container(
                width: (MediaQuery.of(context).size.width - 16) * 0.20,
                child: NumberTextField(
                  controller: ticketQuantityTextController,
                  hintText: "100",
                ),
              ),
              Container(
                width: (MediaQuery.of(context).size.width - 16) * 0.20,
                child: MoneyTextField(
                  controller: ticketPriceTextController,
                  hintText: "\$9.00",
                  textLimit: null,
                ),
              ),
            ],
          ),
          verticalSpaceSmall,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              CustomButton(
                text: !editingTicket ? "Add Ticket" : "Update Ticket",
                textColor: Colors.white,
                backgroundColor: CustomColors.darkMountainGreen,
                height: 30.0,
                width: 120,
                onPressed: validateAndSubmitTicket,
                isBusy: false,
              ),
              SizedBox(width: 8.0),
              CustomIconButton(
                height: 30,
                width: 30,
                icon: Icon(
                  FontAwesomeIcons.trash,
                  size: 14,
                  color: Colors.white,
                ),
                onPressed: deleteTicket,
                centerContent: true,
                backgroundColor: appDestructiveColor(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

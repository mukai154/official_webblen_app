import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/text_field/money_text_field.dart';
import 'package:webblen/ui/widgets/common/text_field/single_line_text_field.dart';

class FeeForm extends StatelessWidget {
  final bool editingFee;
  final TextEditingController feeNameTextController;
  final MoneyMaskedTextController feePriceTextController;
  final VoidCallback validateAndSubmitFee;
  final VoidCallback deleteFee;
  FeeForm({
    required this.editingFee,
    required this.feeNameTextController,
    required this.feePriceTextController,
    required this.validateAndSubmitFee,
    required this.deleteFee,
  });

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
                  width: (MediaQuery.of(context).size.width - 16) * 0.60,
                  child: CustomText(
                    text: 'Fee Name',
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
                width: (MediaQuery.of(context).size.width - 16) * 0.60,
                child: SingleLineTextField(
                  controller: feeNameTextController,
                  hintText: "Venue Fee",
                  textLimit: 50,
                  isPassword: false,
                ),
              ),
              Container(
                width: (MediaQuery.of(context).size.width - 16) * 0.20,
                child: MoneyTextField(
                  controller: feePriceTextController,
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
                text: !editingFee ? "Add Fee" : "Update Fee",
                textColor: Colors.white,
                backgroundColor: CustomColors.darkMountainGreen,
                height: 30.0,
                width: 120,
                onPressed: validateAndSubmitFee,
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
                onPressed: deleteFee,
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

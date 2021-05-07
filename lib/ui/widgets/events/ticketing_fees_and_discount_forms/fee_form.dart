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
      constraints: BoxConstraints(
        maxWidth: 500,
      ),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Container(
            height: 18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.only(right: 4),
                    child: CustomText(
                      text: 'Fee Name',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: appFontColor(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(right: 4),
                    child: CustomText(
                      text: 'Price',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: appFontColor(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
          ),
          verticalSpaceSmall,
          Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.only(right: 4),
                    child: SingleLineTextField(
                      controller: feeNameTextController,
                      hintText: "Venue Fee",
                      textLimit: 50,
                      isPassword: false,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(right: 4),
                    child: MoneyTextField(
                      controller: feePriceTextController,
                      hintText: "\$9.99",
                      textLimit: null,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
          ),
          verticalSpaceSmall,
          Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                CustomButton(
                  text: !editingFee ? "Add Fee" : "Update Fee",
                  textSize: 14,
                  textColor: Colors.white,
                  elevation: 1,
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
          ),
        ],
      ),
    );
  }
}

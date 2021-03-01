import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/enums/reward_type.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/text_field/text_field_container.dart';
import 'package:webblen/ui/widgets/common/webblen_icon_and_balance.dart';

import 'package:webblen/ui/views/wallet/shop/shop_item/shop_item_view_model.dart';

class ShopItemView extends StatelessWidget {
  Widget fieldHeader(String header, bool isRequired) {
    return isRequired
        ? Row(
            children: [
              Text(
                header,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16.0,
                  color: appFontColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "*",
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.red,
                    fontWeight: FontWeight.w500),
              )
            ],
          )
        : Row(
            children: [
              Text(
                header,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 16.0,
                    color: appFontColor(),
                    fontWeight: FontWeight.w500),
              )
            ],
          );
  }

  Widget sizeDropdown(ShopItemViewModel model) {
    return Row(
      children: <Widget>[
        TextFieldContainer(
          height: 45,
          width: 55,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: DropdownButton(
              isExpanded: true,
              underline: Container(),
              value: model.selectedSize,
              items: model.availableSizes.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              }).toList(),
              onChanged: (val) {
                model.changeSelectedSize(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget emailField(ShopItemViewModel model) {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: model.email,
        cursorColor: appCursorColor(),
        validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
        onChanged: (value) {
          model.email = value.trim();
          print(model.email);
        },
        onSaved: (value) => model.email = value.trim(),
        decoration: InputDecoration(
          hintText: "example@email.com",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget locationField(BuildContext context, ShopItemViewModel model) {
    return GestureDetector(
      onTap: () => model.setAddress1(context),
      child: TextFieldContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 40.0,
              padding: EdgeInsets.only(top: 10.0),
              child: CustomText(
                text: model.address1 == null || model.address1.isEmpty
                    ? "Search for Address"
                    : model.address1,
                color: model.address1 == null || model.address1.isEmpty
                    ? appFontColorAlt()
                    : appFontColor(),
                textAlign: TextAlign.left,
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget address2Field(ShopItemViewModel model) {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: model.address2,
        cursorColor: appCursorColor(),
        validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
        onChanged: (value) {
          model.address2 = value.trim();
        },
        onSaved: (value) => model.address2 = value.trim(),
        decoration: InputDecoration(
          hintText: "Optional",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget cashRewardUsernameField(ShopItemViewModel model) {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: model.cashRewardUsername,
        cursorColor: Colors.black,
        validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
        onChanged: (value) {
          model.cashRewardUsername = value.trim();
        },
        onSaved: (value) => model.cashRewardUsername = value.trim(),
        decoration: InputDecoration(
          hintText: model.reward.title.contains("Cash App")
              ? "\$username"
              : model.reward.title.contains("Venmo")
                  ? "@username"
                  : "example@email.com",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget confirmCashRewardUsernameField(ShopItemViewModel model) {
    return TextFieldContainer(
      child: TextFormField(
        initialValue: model.cashRewardUsernameConfirmation,
        cursorColor: Colors.black,
        validator: (value) => value.isEmpty ? 'Field Cannot be Empty' : null,
        onChanged: (value) {
          model.cashRewardUsernameConfirmation = value.trim();
        },
        onSaved: (value) => model.cashRewardUsernameConfirmation = value.trim(),
        decoration: InputDecoration(
          hintText: model.reward.title.contains("Cash App")
              ? "\$username"
              : model.reward.title.contains("Venmo")
                  ? "@username"
                  : "example@email.com",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget merchRewardForm(BuildContext context, ShopItemViewModel model) {
    return Form(
      key: model.merchFormKey,
      child: Column(
        children: [
          fieldHeader("Size", true),
          SizedBox(height: 4),
          sizeDropdown(model),
          SizedBox(height: 24),
          fieldHeader("Email Address", true),
          SizedBox(height: 4),
          emailField(model),
          SizedBox(height: 24),
          fieldHeader("Street Address", true),
          SizedBox(height: 4),
          locationField(context, model),
          SizedBox(height: 24),
          fieldHeader("Apt, Suite, No.", false),
          SizedBox(height: 4),
          address2Field(model),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget cashRewardForm(ShopItemViewModel model) {
    return Form(
      key: model.cashFormKey,
      child: Column(
        children: [
          model.reward.title.contains("PayPal")
              ? Container()
              : fieldHeader("Email Address", true),
          model.reward.title.contains("PayPal")
              ? Container()
              : SizedBox(height: 4),
          model.reward.title.contains("PayPal")
              ? Container()
              : emailField(model),
          model.reward.title.contains("PayPal")
              ? Container()
              : SizedBox(height: 24),
          fieldHeader(
            model.reward.title.contains("Cash App")
                ? "Cash App Tag"
                : model.reward.title.contains("Venmo")
                    ? "Venmo Username"
                    : "PayPal Email",
            true,
          ),
          SizedBox(height: 4),
          cashRewardUsernameField(model),
          SizedBox(height: 24),
          fieldHeader(
            model.reward.title.contains("Cash App")
                ? "Confirm Cash App Tag"
                : model.reward.title.contains("Venmo")
                    ? "Confirm Venmo Username"
                    : "Confirm PayPal Email",
            true,
          ),
          SizedBox(height: 4),
          confirmCashRewardUsernameField(model),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ShopItemViewModel>.reactive(
      disposeViewModel: false,
      initialiseSpecialViewModelsOnce: true,
      onModelReady: (model) => model.initialize(context),
      viewModelBuilder: () => ShopItemViewModel(),
      builder: (context, model, child) => Container(
        height: MediaQuery.of(context).size.height,
        color: appBackgroundColor(),
        child: SafeArea(
          child: Scaffold(
            appBar: CustomAppBar().basicActionAppBar(
              title: 'Details',
              showBackButton: true,
              actionWidget: WebblenIconAndBalance(
                balance: model.user.WBLN,
                fontSize: 18,
              ),
            ),
            body: Container(
              color: appBackgroundColor(),
              child: ListView(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    child: CachedNetworkImage(
                      imageUrl: model.reward.imageURL,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 16.0),
                        Text(
                          model.reward.title,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: appFontColor(),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: <Widget>[
                        //         Image.asset(
                        //           'assets/images/webblen_coin.png',
                        //           height: 20.0,
                        //           width: 20.0,
                        //           fit: BoxFit.contain,
                        //         ),
                        //         SizedBox(
                        //           width: 4.0,
                        //         ),
                        //         Text(
                        //           model.reward.cost.toStringAsFixed(2),
                        //           style: TextStyle(
                        //               color: Colors.black,
                        //               fontSize: 16,
                        //               fontWeight: FontWeight.w500),
                        //         ),
                        //       ],
                        //     ),
                        //   ],
                        // ),
                        WebblenIconAndBalance(
                          balance: model.reward.cost,
                          fontSize: 16,
                        ),
                        SizedBox(height: 32),
                        model.reward.rewardType == RewardType.webblenClothes
                            ? merchRewardForm(context, model)
                            : cashRewardForm(model),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              height: 80.0,
              decoration: BoxDecoration(
                color: appBackgroundColor(),
                border: Border(
                  top: BorderSide(
                    color: appDividerColor(),
                    width: 1.5,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Total",
                          style: TextStyle(
                            color: appFontColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        WebblenIconAndBalance(
                          balance: model.reward.cost,
                          fontSize: 16,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CustomButton(
                          text: "Purchase",
                          textSize: 14.0,
                          textColor: Colors.white,
                          backgroundColor: CustomColors.darkMountainGreen,
                          height: 35.0,
                          width: MediaQuery.of(context).size.width * 0.4,
                          isBusy: false,
                          onPressed: () => model.purchaseReward(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/events/tickets/tickets_purchase_success/tickets_purchase_success_view_model.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';

class TicketsPurchaseSuccessView extends StatelessWidget {
  final String? email;
  TicketsPurchaseSuccessView(@PathParam() this.email);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TicketsPurchaseSuccessViewModel>.reactive(
      viewModelBuilder: () => TicketsPurchaseSuccessViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicAppBar(
          title: "Tickets Purchased",
          showBackButton: false,
        ),
        body: Container(
          height: screenHeight(context),
          color: appBackgroundColor(),
          child: ListView(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                color: appBackgroundColor(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    verticalSpaceLarge,
                    CustomText(
                      text: "Ticket Purchase Successful!",
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: appFontColor(),
                      textAlign: TextAlign.center,
                    ),
                    verticalSpaceSmall,
                    CustomText(
                      text: "An email was sent to $email",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: appFontColor(),
                      textAlign: TextAlign.center,
                    ),
                    verticalSpaceSmall,
                    CustomText(
                      text: "Your tickets are located in your wallet.\nFeel free to share and screenshot them!",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: appFontColor(),
                      textAlign: TextAlign.center,
                    ),
                    verticalSpaceMedium,
                    CustomButton(
                      text: "View Wallet",
                      textSize: 16,
                      height: 40,
                      width: 300,
                      onPressed: () => model.customNavigationService.navigateToWalletView(),
                      backgroundColor: appButtonColor(),
                      textColor: appFontColor(),
                      elevation: 1,
                      isBusy: false,
                    ),
                    verticalSpaceLarge,
                    CustomText(
                      text: "If you have any issues with the event are tickets, please contact team@webblen.com for support.",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: appFontColor(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

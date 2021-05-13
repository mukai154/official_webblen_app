import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/constants/custom_colors.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/views/events/check_in/scan_attendees/scan_attendees_view_model.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';

class ScanAttendeesView extends StatelessWidget {
  final String? id;
  ScanAttendeesView({@PathParam() this.id});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ScanAttendeesViewModel>.reactive(
      viewModelBuilder: () => ScanAttendeesViewModel(),
      onModelReady: (model) => model.initialize(id),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicAppBar(
          title: "Ticket Scanner",
          showBackButton: true,
        ),
        body: Container(
          height: screenHeight(context),
          child: model.isBusy
              ? Center(
                  child: CustomCircleProgressIndicator(
                    size: 10,
                    color: appActiveColor(),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: QRView(
                        key: model.qrKey,
                        onQRViewCreated: model.onQRViewCreated,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Container(
                          width: screenWidth(context),
                          color: model.scanError == null
                              ? appBackgroundColor()
                              : model.scanError!
                                  ? appDestructiveColor()
                                  : CustomColors.darkMountainGreen,
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              CustomText(
                                text: model.event.title,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: model.scanError == null ? appFontColor() : Colors.white,
                                textAlign: TextAlign.center,
                              ),
                              verticalSpaceSmall,
                              model.scanning
                                  ? CustomText(
                                      text: "Scanning...",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: model.scanError == null ? appFontColor() : Colors.white,
                                      textAlign: TextAlign.center,
                                    )
                                  : Container(
                                      width: 200,
                                      child: CustomButton(
                                        onPressed: () => model.resumeScanner(),
                                        backgroundColor: Colors.white,
                                        text: "Scan Ticket",
                                        height: 40,
                                        textColor: Colors.black,
                                        elevation: 1,
                                        isBusy: false,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

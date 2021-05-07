import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/models/webblen_event_ticket.dart';
import 'package:webblen/ui/ui_helpers/ui_helpers.dart';
import 'package:webblen/ui/widgets/common/custom_text.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';
import 'package:webblen/ui/widgets/common/progress_indicator/custom_circle_progress_indicator.dart';

import 'ticket_details_view_model.dart';

class TicketDetailsView extends StatelessWidget {
  final String? id;
  TicketDetailsView(@PathParam() this.id);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TicketDetailsViewModel>.reactive(
      onModelReady: (model) => model.initialize(id: id!),
      viewModelBuilder: () => TicketDetailsViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicAppBar(
          title: "Ticket Details",
          showBackButton: true,
        ),
        body: Container(
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
                            _TicketDetails(ticket: model.ticket!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _TicketDetails extends StatelessWidget {
  final WebblenEventTicket ticket;
  _TicketDetails({required this.ticket});
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 500,
      ),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: appBackgroundColor(),
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            height: 220,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: QrImage(
              data: ticket.id!,
              version: QrVersions.auto,
              size: 200.0,
            ),
            //              Column(
            //                crossAxisAlignment: CrossAxisAlignment.stretch,
            //                children: <Widget>[
            //                  Row(
            //                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                    children: <Widget>[
            //                      WebblenLogo(),
            //                      TagContainer(tag: "Concert/Performance"),
            //                    ],
            //                  ),
            //                  SizedBox(height: 10.0),
            //                  Center(
            //                    child: QrImage(
            //                      data: "1234567890",
            //                      version: QrVersions.auto,
            //                      size: 150.0,
            //                    ),
            //                  ),
            //                ],
            //              ),
          ),
          Container(
            height: 250,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(4.0),
                  margin: EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    color: appTextFieldContainerColor(),
                  ),
                  child: CustomText(
                    text: ticket.eventTitle,
                    textAlign: TextAlign.center,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appFontColor(),
                  ),
                ),
                CustomText(
                  text: "Ticket Type:",
                  textAlign: TextAlign.left,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: appFontColor(),
                ),
                CustomText(
                  text: ticket.name,
                  textAlign: TextAlign.left,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: appFontColor(),
                ),
                SizedBox(height: 8.0),
                CustomText(
                  text: "Address:",
                  textAlign: TextAlign.left,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: appFontColor(),
                ),
                CustomText(
                  text: ticket.address,
                  textAlign: TextAlign.left,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: appFontColor(),
                ),
                SizedBox(height: 8.0),
                CustomText(
                  text: "Start Date & Time:",
                  textAlign: TextAlign.left,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: appFontColor(),
                ),
                CustomText(
                  text: "${ticket.startDate} | ${ticket.startTime}",
                  textAlign: TextAlign.left,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: appFontColor(),
                ),
                SizedBox(height: 8.0),
                CustomText(
                  text: "End Date & Time:",
                  textAlign: TextAlign.left,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: appFontColor(),
                ),
                CustomText(
                  text: "${ticket.endDate} | ${ticket.endTime}",
                  textAlign: TextAlign.left,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: appFontColor(),
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

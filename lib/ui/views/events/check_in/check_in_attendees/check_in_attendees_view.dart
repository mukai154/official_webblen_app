import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:webblen/constants/app_colors.dart';
import 'package:webblen/ui/widgets/common/buttons/custom_button.dart';
import 'package:webblen/ui/widgets/common/navigation/app_bar/custom_app_bar.dart';

import 'check_in_attendees_view_model.dart';

class CheckInAttendeesView extends StatelessWidget {
  final String? id;
  CheckInAttendeesView({@PathParam() this.id});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CheckInAttendeesViewModel>.reactive(
      viewModelBuilder: () => CheckInAttendeesViewModel(),
      onModelReady: (model) => model.initialize(id),
      builder: (context, model, child) => Scaffold(
        appBar: CustomAppBar().basicAppBar(
          title: "Check In Attendees",
          showBackButton: true,
        ),
        body: Container(
          color: Theme.of(context).backgroundColor,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: ListView(
            children: [
              CustomFlatButton(
                onTap: () => model.navigateToScanTickets(),
                fontColor: appFontColor(),
                fontSize: 16,
                text: "Scan Tickets",
                showBottomBorder: true,
                textAlign: TextAlign.left,
              ),
              CustomFlatButton(
                onTap: () => model.navigateToAttendeeSearch(),
                fontColor: appFontColor(),
                fontSize: 16,
                text: "Search Sold Tickets",
                showBottomBorder: false,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
